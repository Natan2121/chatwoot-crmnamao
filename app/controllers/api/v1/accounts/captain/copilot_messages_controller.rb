# frozen_string_literal: true

class Api::V1::Accounts::Captain::CopilotMessagesController < Api::V1::Accounts::BaseController
  before_action :set_copilot_thread
  before_action :ensure_message, only: :create

  def index
    copilot_messages = @copilot_thread
                       .copilot_messages
                       .order(created_at: :asc)
                       .page(permitted_params[:page] || 1)
                       .per(1000)

    render json: {
      payload: copilot_messages.map(&:api_payload),
      meta: {
        total_count: copilot_messages.size,
        page: (permitted_params[:page] || 1).to_i
      }
    }
  end

  def create
    ActiveRecord::Base.transaction do
      @copilot_message = @copilot_thread.copilot_messages.create!(
        message: { content: normalized_message_content },
        message_type: :user
      )

      assistant_message = Captain::Copilot::ChatService.new(
        account: Current.account,
        assistant: @copilot_thread.assistant,
        user: Current.user,
        copilot_thread: @copilot_thread,
        conversation_display_id: params[:conversation_id]
      ).perform

      @copilot_thread.copilot_messages.create!(
        message: assistant_message,
        message_type: :assistant
      )
    end

    render json: @copilot_message.api_payload
  end

  private

  def set_copilot_thread
    @copilot_thread = Current.account.copilot_threads.find_by!(
      id: params[:copilot_thread_id],
      user: Current.user
    )
  end

  def normalized_message_content
    raw = params[:message]
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
