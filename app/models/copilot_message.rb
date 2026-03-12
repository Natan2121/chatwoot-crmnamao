# frozen_string_literal: true

class CopilotMessage < ApplicationRecord
  belongs_to :copilot_thread
  belongs_to :account

  enum :message_type, { user: 0, assistant: 1, assistant_thinking: 2 }

  validates :message_type, presence: true
  validates :message, presence: true

  before_validation :ensure_account
  validate :validate_message_attributes

  def push_event_data
    {
      id: id,
      message: message,
      message_type: message_type,
      created_at: created_at.to_i,
      copilot_thread: copilot_thread.push_event_data,
      account_id: account_id
    }
  end

  alias api_payload push_event_data

  private

  def ensure_account
    self.account_id = copilot_thread&.account_id
  end

  def validate_message_attributes
    return if message.blank?

    allowed_keys = %w[content reasoning function_name reply_suggestion]
    invalid_keys = message.keys - allowed_keys
    errors.add(:message, "contains invalid attributes: #{invalid_keys.join(', ')}") if invalid_keys.any?
  end
end
