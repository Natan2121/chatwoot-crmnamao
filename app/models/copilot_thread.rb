# frozen_string_literal: true

class CopilotThread < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :assistant, class_name: 'Captain::Assistant'

  has_many :copilot_messages, dependent: :destroy_async

  validates :title, presence: true

  def push_event_data
    {
      id: id,
      title: title,
      created_at: created_at.to_i,
      user: user.push_event_data,
      assistant: assistant.push_event_data,
      account_id: account_id
    }
  end

  alias api_payload push_event_data

  def previous_history
    copilot_messages
      .where(message_type: %i[user assistant])
      .order(created_at: :asc)
      .map do |copilot_message|
        {
          content: copilot_message.message['content'],
          role: copilot_message.message_type
        }
      end
  end
end
