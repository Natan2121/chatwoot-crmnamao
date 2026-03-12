require 'rails_helper'

RSpec.describe Captain::Copilot::ChatService do
  subject(:service) do
    described_class.new(
      account: account,
      assistant: assistant,
      user: agent,
      copilot_thread: copilot_thread,
      conversation_display_id: conversation.display_id
    )
  end

  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, name: 'Agente CRM') }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let(:assistant) do
    create(
      :captain_assistant,
      account: account,
      name: 'Copiloto CRM',
      description: 'Ajuda operadores a responder no Chatwoot'
    )
  end
  let(:copilot_thread) do
    create(
      :captain_copilot_thread,
      account: account,
      user: agent,
      assistant: assistant,
      title: 'Resumir esta conversa'
    )
  end
  let(:captured_messages) { [] }
  let(:mock_chat) { instance_double(RubyLLM::Chat) }
  let(:mock_context) { instance_double(RubyLLM::Context, chat: mock_chat) }
  let(:mock_response) do
    instance_double(
      RubyLLM::Message,
      content: 'Resumo pronto',
      input_tokens: 120,
      output_tokens: 40
    )
  end

  before do
    create(:installation_config, name: 'CAPTAIN_OPEN_AI_API_KEY', value: 'test-key')
    create(
      :message,
      conversation: conversation,
      message_type: :incoming,
      content: 'Teste do app Funis em staging'
    )
    create(
      :captain_copilot_message,
      copilot_thread: copilot_thread,
      message_type: :user,
      message: { content: 'Resuma esta conversa' }
    )

    allow(account).to receive(:feature_enabled?).and_call_original
    allow(account).to receive(:feature_enabled?).with('captain_tasks').and_return(true)

    allow(Llm::Config).to receive(:with_api_key).and_yield(mock_context)
    allow(mock_chat).to receive(:with_instructions) do |prompt|
      captured_messages << { role: 'system', content: prompt }
      mock_chat
    end
    allow(mock_chat).to receive(:add_message) do |message|
      captured_messages << message
      mock_chat
    end
    allow(mock_chat).to receive(:ask) do |message|
      captured_messages << { role: 'user', content: message }
      mock_response
    end
  end

  it 'inclui o contexto da conversa no mesmo system prompt consumido pelo modelo' do
    result = service.perform

    system_prompt = captured_messages.find { |message| message[:role] == 'system' }[:content]

    expect(result[:message]).to eq('Resumo pronto')
    expect(system_prompt).to include('Contexto da conversa aberta no Chatwoot:')
    expect(system_prompt).to include('Message History:')
    expect(system_prompt).to include('User: Teste do app Funis em staging')
    expect(captured_messages.count { |message| message[:role] == 'system' }).to eq(1)
  end
end
