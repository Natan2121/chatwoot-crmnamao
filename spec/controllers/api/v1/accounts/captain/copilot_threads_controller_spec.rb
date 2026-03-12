# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::Captain::CopilotThreads', type: :request do
  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:assistant) { create(:captain_assistant, account: account) }
  let(:conversation) { create(:conversation, account: account) }

  describe 'GET /api/v1/accounts/{account.id}/captain/copilot_threads' do
    it 'returns only threads from the current user' do
      create_list(:captain_copilot_thread, 2, account: account, user: agent, assistant: assistant)
      create(:captain_copilot_thread, account: account, user: admin, assistant: assistant)

      get "/api/v1/accounts/#{account.id}/captain/copilot_threads",
          headers: agent.create_new_auth_token,
          as: :json

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['payload'].length).to eq(2)
      expect(response.parsed_body['payload'].pluck('user').pluck('id').uniq).to eq([agent.id])
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/captain/copilot_threads' do
    let(:service) { instance_double(Captain::Copilot::ChatService, perform: { content: 'Sugestao pronta', reply_suggestion: true }) }
    let(:params) do
      {
        message: 'Sugira uma resposta para esse cliente',
        assistant_id: assistant.id,
        conversation_id: conversation.display_id
      }
    end

    before do
      allow(Captain::Copilot::ChatService).to receive(:new).and_return(service)
    end

    it 'creates the thread, user message and assistant response' do
      expect do
        post "/api/v1/accounts/#{account.id}/captain/copilot_threads",
             headers: agent.create_new_auth_token,
             params: params,
             as: :json
      end.to change(CopilotThread, :count).by(1)
         .and change(CopilotMessage, :count).by(2)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['title']).to eq(params[:message])
      expect(Captain::Copilot::ChatService).to have_received(:new)
      expect(CopilotMessage.order(:id).last.message).to eq(
        'content' => 'Sugestao pronta',
        'reply_suggestion' => true
      )
    end

    it 'rejects blank messages' do
      post "/api/v1/accounts/#{account.id}/captain/copilot_threads",
           headers: agent.create_new_auth_token,
           params: params.merge(message: ''),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['error']).to eq(I18n.t('captain.copilot_message_required'))
    end
  end
end
