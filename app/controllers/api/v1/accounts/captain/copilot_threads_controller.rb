# frozen_string_literal: true

class Api::V1::Accounts::Captain::CopilotThreadsController < Api::V1::Accounts::BaseController
  before_action :ensure_message, only: :create

  def index
    copilot_threads = Current.account.copilot_threads
                              .where(user_id: Current.user.id)
                              .includes(:user, :assistant)
                              .order(created_at: :desc)
                              .page(permitted_params[:page] || 1)
                              .per(5)

    render json: {
      payload: copilot_threads.map(&:api_payload),
      meta: {
        total_count: copilot_threads.size,
        page: (permitted_params[:page] || 1).to_i
      }
    }
  end

  def create
    assistant = selected_assistant

    ActiveRecord::Base.transaction do
      @copilot_thread = Current.account.copilot_threads.create!(
        title: normalized_message_content,
        user: Current.user,
        assistant: assistant
      )

      @copilot_thread.copilot_messages.create!(
        message_type: :user,
        message: { content: normalized_message_content }
      )

      assistant_message = Captain::Copilot::ChatService.new(
        account: Current.account,
        assistant: assistant,
        user: Current.user,
        copilot_thread: @copilot_thread,
        conversation_display_id: copilot_thread_params[:conversation_id]
      ).perform

      @copilot_thread.copilot_messages.create!(
        message_type: :assistant,
        message: assistant_message
      )
    end

    render json: @copilot_thread.api_payload
  end

  private

  def selected_assistant
    return Captain::Assistant.ensure_default_for!(Current.account) if copilot_thread_params[:assistant_id].blank?

    Current.account.captain_assistants.find(copilot_thread_params[:assistant_id])
  end

  def copilot_thread_params
    params.permit(:message, :assistant_id, :conversation_id)
  end

  def normalized_message_content
    raw = copilot_thread_params[:message]
    return raw if raw.is_a?(String)

    raw[:content] || raw['content'] || raw[:text] || raw['text']
  end

  def ensure_message
    return if normalized_message_content.present?

    render_could_not_create_error(I18n.t('captain.copilot_message_required'))
  end

  def permitted_params
    params.permit(:page)
  end
end
