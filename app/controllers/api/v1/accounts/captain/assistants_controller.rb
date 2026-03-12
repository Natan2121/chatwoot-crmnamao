# frozen_string_literal: true

class Api::V1::Accounts::Captain::AssistantsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action -> { check_authorization(Captain::Assistant) }
  before_action :set_assistant, only: [:show, :update, :destroy, :playground]

  def index
    Captain::Assistant.ensure_default_for!(Current.account)
    assistants = Current.account.captain_assistants.ordered

    render json: {
      payload: assistants.map(&:api_payload),
      meta: {
        total_count: assistants.count,
        page: 1
      }
    }
  end

  def show
    render json: @assistant.api_payload
  end

  def create
    @assistant = Current.account.captain_assistants.create!(assistant_params)
    render json: @assistant.api_payload
  end

  def update
    @assistant.update!(assistant_params)
    render json: @assistant.api_payload
  end

  def destroy
    @assistant.destroy!
    head :no_content
  end

  def playground
    return render_could_not_create_error(I18n.t('captain.copilot_message_required')) if params[:message_content].blank?

    history = message_history + [{ role: 'user', content: params[:message_content] }]
    fake_thread = Struct.new(:previous_history).new(history)

    response = Captain::Copilot::ChatService.new(
      account: Current.account,
      assistant: @assistant,
      user: Current.user,
      copilot_thread: fake_thread,
      conversation_display_id: params[:conversation_id]
    ).perform

    render json: { message: response[:content] }
  end

  def tools
    render json: {
      payload: [],
      meta: {
        total_count: 0,
        page: 1
      }
    }
  end

  private

  def set_assistant
    @assistant = Current.account.captain_assistants.find(params[:id])
  end

  def assistant_params
    permitted = params.require(:assistant).permit(
      :name,
      :description,
      config: [
        :product_name,
        :feature_faq,
        :feature_memory,
        :feature_citation,
        :welcome_message,
        :handoff_message,
        :resolution_message,
        :instructions,
        :temperature
      ],
      response_guidelines: [],
      guardrails: []
    )

    permitted.to_h
  end

  def message_history
    Array(params[:message_history]).map do |message|
      {
        role: message[:role] || message['role'],
        content: message[:content] || message['content']
      }
    end
  end
end
