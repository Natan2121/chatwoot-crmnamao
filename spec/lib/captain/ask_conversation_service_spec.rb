require 'rails_helper'

RSpec.describe Captain::AskConversationService do
  subject(:service) do
    described_class.new(
      account: account,
      user_message: 'Qual foi a ultima mensagem do cliente?',
      conversation_display_id: conversation.display_id
    )
  end

  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let(:captured_messages) { [] }
  let(:mock_chat) { instance_double(RubyLLM::Chat) }
  let(:mock_context) { instance_double(RubyLLM::Context, chat: mock_chat) }
  let(:mock_response) do
    instance_double(
      RubyLLM::Message,
      content: 'A ultima mensagem do cliente foi: Preciso validar o funil.',
      input_tokens: 80,
      output_tokens: 30
    )
  end

  before do
    create(:installation_config, name: 'CAPTAIN_OPEN_AI_API_KEY', value: 'test-key')
    create(
      :message,
      conversation: conversation,
      message_type: :incoming,
      content: 'Preciso validar o funil.'
    )

    allow(account).to receive(:feature_enabled?).and_call_original
    allow(account).to receive(:feature_enabled?).with('captain_tasks').and_return(true)

    allow(Llm::Config).to receive(:with_api_key).and_yield(mock_context)
    allow(mock_chat).to receive(:with_instructions) do |prompt|
      captured_messages << { role: 'system', content: prompt }
      mock_chat
    end
    allow(mock_chat).to receive(:ask) do |message|
      captured_messages << { role: 'user', content: message }
      mock_response
    end
  end

  it 'envia a pergunta do operador junto com o contexto da conversa' do
    result = service.perform

    expect(result[:message]).to include('A ultima mensagem do cliente')
    expect(captured_messages.find { |message| message[:role] == 'system' }[:content]).to include('portugues do Brasil')

    user_prompt = captured_messages.find { |message| message[:role] == 'user' }[:content]
    expect(user_prompt).to include('Contexto da conversa aberta no Chatwoot:')
    expect(user_prompt).to include('User: Preciso validar o funil.')
    expect(user_prompt).to include('Pergunta do operador:')
    expect(user_prompt).to include('Qual foi a ultima mensagem do cliente?')
  end
end
