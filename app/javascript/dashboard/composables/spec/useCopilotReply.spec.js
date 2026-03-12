import { nextTick, ref } from 'vue';
import { useCopilotReply } from '../useCopilotReply';

const mockProcessEvent = vi.fn();
const mockFollowUp = vi.fn();
const mockUpdateUISettings = vi.fn();
const currentChat = ref({ id: '737' });
const captainEnabled = ref(false);

vi.mock('dashboard/composables/useCaptain', () => ({
  useCaptain: () => ({
    processEvent: mockProcessEvent,
    followUp: mockFollowUp,
    currentChat,
    captainEnabled,
  }),
}));

vi.mock('dashboard/composables/useUISettings', () => ({
  useUISettings: () => ({
    updateUISettings: mockUpdateUISettings,
  }),
}));

vi.mock('dashboard/composables', () => ({
  useTrack: vi.fn(),
}));

vi.mock('dashboard/helper/AnalyticsHelper/events', () => ({
  CAPTAIN_EVENTS: {
    GENERATION_FAILED: 'generation_failed',
    REWRITE_USED: 'rewrite_used',
    REWRITE_APPLIED: 'rewrite_applied',
    REWRITE_DISMISSED: 'rewrite_dismissed',
    SUMMARIZE_USED: 'summarize_used',
    SUMMARIZE_APPLIED: 'summarize_applied',
    SUMMARIZE_DISMISSED: 'summarize_dismissed',
    REPLY_SUGGESTION_USED: 'reply_suggestion_used',
    REPLY_SUGGESTION_APPLIED: 'reply_suggestion_applied',
    REPLY_SUGGESTION_DISMISSED: 'reply_suggestion_dismissed',
    FOLLOW_UP_SENT: 'follow_up_sent',
  },
}));

describe('useCopilotReply', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    captainEnabled.value = false;
    currentChat.value = { id: '737' };
  });

  it('does not open copilot when captain integration is disabled', async () => {
    const { execute } = useCopilotReply();

    await execute('ask_copilot');
    await nextTick();

    expect(mockUpdateUISettings).not.toHaveBeenCalled();
    expect(mockProcessEvent).not.toHaveBeenCalled();
  });

  it('opens copilot panel when captain integration is enabled', async () => {
    captainEnabled.value = true;
    const { execute } = useCopilotReply();

    await execute('ask_copilot');

    expect(mockUpdateUISettings).toHaveBeenCalledWith({
      is_contact_sidebar_open: false,
      is_copilot_panel_open: true,
    });
  });
});
