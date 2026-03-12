class Captain::AskConversationService < Captain::BaseTaskService
  pattr_initialize [:account!, :user_message!, :conversation_display_id!]

  def perform
    make_api_call(
      model: GPT_MODEL,
      messages: [
        { role: 'system', content: system_prompt },
        { role: 'user', content: ask_prompt }
      ]
    )
  end

  private

  def ask_prompt
    <<~PROMPT
      Contexto da conversa aberta no Chatwoot:
      #{conversation.to_llm_text(include_contact_details: false)}

      Pergunta do operador:
      #{user_message}
    PROMPT
  end

  def system_prompt
    <<~PROMPT
      Voce e um assistente interno para operadores do Chatwoot.
      Responda sempre em portugues do Brasil.
      Use apenas o contexto fornecido da conversa para responder.
      Se a conversa nao tiver informacao suficiente, diga exatamente o que falta.
      Nao invente fatos, datas, nomes, promessas ou proximos passos.
      Quando fizer sentido, cite a mensagem ou o ponto da conversa em que voce se baseou.
      Responda de forma direta e operacional.
    PROMPT
  end

  def event_name
    'ask_conversation'
  end
end
