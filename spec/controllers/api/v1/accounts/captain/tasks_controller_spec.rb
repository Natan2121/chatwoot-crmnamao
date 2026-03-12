# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::Captain::Tasks', type: :request do
  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, role: :agent) }

  def json_response
    response.parsed_body
  end

  describe 'POST /api/v1/accounts/{account.id}/captain/tasks/summarize' do
    let(:conversation_display_id) { 42 }

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post "/api/v1/accounts/#{account.id}/captain/tasks/summarize",
             params: { conversation_display_id: conversation_display_id },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an agent' do
      let(:summary_service) { instance_double(Captain::SummaryService, perform: { message: 'Resumo gerado' }) }

      before do
        allow(Captain::SummaryService).to receive(:new) do |**kwargs|
          expect(kwargs[:account]).to eq(account)
          expect(kwargs[:conversation_display_id].to_i).to eq(conversation_display_id)
          summary_service
        end
      end

      it 'returns the generated summary' do
        post "/api/v1/accounts/#{account.id}/captain/tasks/summarize",
             headers: agent.create_new_auth_token,
             params: { conversation_display_id: conversation_display_id },
             as: :json

        expect(response).to have_http_status(:success)
        expect(json_response).to eq('message' => 'Resumo gerado')
        expect(Captain::SummaryService).to have_received(:new)
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/captain/tasks/reply_suggestion' do
    let(:conversation_display_id) { 43 }
    let(:reply_service) { instance_double(Captain::ReplySuggestionService, perform: { message: 'Resposta sugerida' }) }

    before do
      allow(Captain::ReplySuggestionService).to receive(:new) do |**kwargs|
        expect(kwargs[:account]).to eq(account)
        expect(kwargs[:conversation_display_id].to_i).to eq(conversation_display_id)
        expect(kwargs[:user]).to eq(agent)
        reply_service
      end
    end

    it 'returns the suggested reply' do
      post "/api/v1/accounts/#{account.id}/captain/tasks/reply_suggestion",
           headers: agent.create_new_auth_token,
           params: { conversation_display_id: conversation_display_id },
           as: :json

      expect(response).to have_http_status(:success)
      expect(json_response).to eq('message' => 'Resposta sugerida')
      expect(Captain::ReplySuggestionService).to have_received(:new)
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/captain/tasks/ask_conversation' do
    let(:conversation_display_id) { 44 }
    let(:question) { 'Qual foi a ultima mensagem do cliente?' }
    let(:ask_service) { instance_double(Captain::AskConversationService, perform: { message: 'A ultima mensagem foi um teste do app.' }) }

    before do
      allow(Captain::AskConversationService).to receive(:new) do |**kwargs|
        expect(kwargs[:account]).to eq(account)
        expect(kwargs[:conversation_display_id].to_i).to eq(conversation_display_id)
        expect(kwargs[:user_message]).to eq(question)
        ask_service
      end
    end

    it 'returns the contextual answer' do
      post "/api/v1/accounts/#{account.id}/captain/tasks/ask_conversation",
           headers: agent.create_new_auth_token,
           params: {
             conversation_display_id: conversation_display_id,
             message: question,
           },
           as: :json

      expect(response).to have_http_status(:success)
      expect(json_response).to eq('message' => 'A ultima mensagem foi um teste do app.')
      expect(Captain::AskConversationService).to have_received(:new)
    end
  end
end
