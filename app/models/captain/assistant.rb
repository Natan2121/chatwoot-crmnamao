# frozen_string_literal: true

class Captain::Assistant < ApplicationRecord
  self.table_name = 'captain_assistants'

  belongs_to :account
  has_many :copilot_threads, foreign_key: :assistant_id, dependent: :destroy_async

  store_accessor :config,
                 :product_name,
                 :feature_faq,
                 :feature_memory,
                 :feature_citation,
                 :welcome_message,
                 :handoff_message,
                 :resolution_message,
                 :instructions,
                 :temperature

  validates :name, presence: true
  validates :description, presence: true
  validates :account_id, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  def self.ensure_default_for!(account)
    account.captain_assistants.ordered.first || account.captain_assistants.create!(default_attributes_for(account))
  end

  def self.default_attributes_for(account)
    {
      name: 'Copiloto CRM',
      description: 'Assistente interno para resumir conversas, sugerir respostas e apoiar o atendimento em portugues do Brasil.',
      config: {
        product_name: account.name,
        instructions: 'Responda sempre em portugues do Brasil e priorize instrucoes praticas para o agente.'
      }
    }
  end

  def available_name
    name
  end

  def push_event_data
    {
      id: id,
      name: name,
      description: description,
      created_at: created_at.to_i,
      type: 'captain_assistant'
    }
  end

  def api_payload
    push_event_data.merge(
      account_id: account_id,
      config: config,
      guardrails: guardrails,
      response_guidelines: response_guidelines,
      updated_at: updated_at.to_i
    )
  end
end
