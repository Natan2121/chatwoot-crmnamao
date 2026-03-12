# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::Captain::CopilotMessages', type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account, role: :administrator) }
  let(:assistant) { create(:captain_assistant, account: account) }
  let(:copilot_thread) { create(:captain_copilot_thread, account: account, user: user, assistant: assistant) }
  let!(:copilot_message) { create(:captain_copilot_message, copilot_thread: copilot_thread, account: account) }

  describe 'GET /api/v1/accounts/{account.id}/captain/copilot_threads/{thread.id}/copilot_messages' do
    it 'returns the full thread history' do
      get "/api/v1/accounts/#{account.id}/captain/copilot_threads/#{copilot_thread.id}/copilot_messages",
          headers: user.create_new_auth_token,
          as: :json

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['payload'].length).to eq(1)
      expect(response.parsed_body['payload'][0]['id']).to eq(copilot_message.id)
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/captain/copilot_threads/{thread.id}/copilot_messages' do
    let(:service) { instance_double(Captain::Copilot::ChatService, perform: { content: 'Posso responder assim para o cliente.', reply_suggestion: true }) }

    before do
      allow(Captain::Copilot::ChatService).to receive(:new).and_return(service)
    end

    it 'creates a user message and an assistant response' do
      expect do
        post "/api/v1/accounts/#{account.id}/captain/copilot_threads/#{copilot_thread.id}/copilot_messages",
             params: { message: 'Refine esse texto', conversation_id: 123 },
             headers: user.create_new_auth_token,
             as: :json
      end.to change(CopilotMessage, :count).by(2)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['message']).to eq('content' => 'Refine esse texto')
      expect(CopilotMessage.order(:id).last.message).to eq(
        'content' => 'Posso responder assim para o cliente.',
        'reply_suggestion' => true
      )
    end
  end
end
