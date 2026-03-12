# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::Captain::Assistants', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }

  describe 'GET /api/v1/accounts/{account.id}/captain/assistants' do
    it 'creates and returns a default assistant for authenticated users' do
      expect do
        get "/api/v1/accounts/#{account.id}/captain/assistants",
            headers: agent.create_new_auth_token,
            as: :json
      end.to change(Captain::Assistant, :count).by(1)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['payload'].length).to eq(1)
      expect(response.parsed_body['payload'][0]['name']).to eq('Copiloto CRM')
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/captain/assistants' do
    let(:params) do
      {
        assistant: {
          name: 'Especialista WhatsApp',
          description: 'Apoia o agente em respostas comerciais',
          config: {
            product_name: 'CRM na Mao'
          }
        }
      }
    end

    it 'allows administrators to create assistants' do
      expect do
        post "/api/v1/accounts/#{account.id}/captain/assistants",
             headers: admin.create_new_auth_token,
             params: params,
             as: :json
      end.to change(Captain::Assistant, :count).by(1)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['name']).to eq('Especialista WhatsApp')
    end

    it 'rejects non-admin users' do
      post "/api/v1/accounts/#{account.id}/captain/assistants",
           headers: agent.create_new_auth_token,
           params: params,
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
