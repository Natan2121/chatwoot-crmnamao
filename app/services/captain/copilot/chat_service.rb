# frozen_string_literal: true

class Captain::Copilot::ChatService < Captain::BaseTaskService
  pattr_initialize [:account!, :assistant!, :user!, :copilot_thread!, { conversation_display_id: nil }]

  def perform
    result = make_api_call(
      model: account.captain_copilot_model,
      messages: build_messages
    )

    if result[:error]
      return {
        content: result[:error],
        reply_suggestion: false
      }
    end

    {
      content: result[:message].presence || fallback_message,
      reply_suggestion: conversation.present?
    }
  end

  private

  def build_messages
    messages = [{ role: 'system', content: system_prompt }]
    messages << { role: 'system', content: formatted_conversation_context } if conversation.present?
    messages.concat(copilot_thread.previous_history)
    messages
  end

  def system_prompt
    [
      "Voce e #{assistant.name}, um copiloto interno do Chatwoot para agentes de atendimento.",
      'Responda sempre em portugues do Brasil.',
      'Seu publico e o agente humano, nao o cliente final.',
      'Quando o agente pedir uma resposta para enviar ao cliente, devolva um texto pronto para copiar e colar.',
      'Se faltar contexto, diga explicitamente o que falta e nao invente fatos.',
      "Empresa ou produto: #{assistant.config['product_name'].presence || account.name}.",
      "Descricao do assistente: #{assistant.description}.",
      additional_instructions
    ].compact.join("\n")
  end

  def additional_instructions
    instructions = assistant.config['instructions'].presence
    return nil if instructions.blank?

    "Instrucoes adicionais: #{instructions}"
  end

  def formatted_conversation_context
    <<~PROMPT.strip
      Contexto da conversa aberta no Chatwoot:
      #{LlmFormatter::ConversationLlmFormatter.new(conversation).format(token_limit: TOKEN_LIMIT)}
    PROMPT
  end

  def fallback_message
    'Nao consegui gerar uma resposta util agora. Tente reformular o pedido.'
  end

  def event_name
    'copilot'
  end
end
