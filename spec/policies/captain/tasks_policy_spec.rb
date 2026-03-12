require 'rails_helper'

RSpec.describe Captain::TasksPolicy, type: :policy do
  subject { described_class }

  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:agent_context) do
    {
      user: agent,
      account: account,
      account_user: agent.account_users.find_by(account: account)
    }
  end

  permissions :ask_conversation? do
    it 'allows authenticated agents to ask about the current conversation' do
      expect(described_class).to permit(agent_context, :'captain/tasks')
    end
  end
end
