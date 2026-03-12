import { nextTick, ref } from 'vue';
import { useCopilotReply } from '../useCopilotReply';

const mockProcessEvent = vi.fn();
const mockFollowUp = vi.fn();
const mockAskConversation = vi.fn();
const currentChat = ref({ id: '737' });
const captainTasksEnabled = ref(false);

vi.mock('dashboard/composables/useCaptain', () => ({
  useCaptain: () => ({
    processEvent: mockProcessEvent,
    followUp: mockFollowUp,
    askConversation: mockAskConversation,
    currentChat,
    captainTasksEnabled,
  }),
}));

vi.mock('dashboard/composables/useUISettings', () => ({
  useUISettings: () => ({
    updateUISettings: vi.fn(),
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
    captainTasksEnabled.value = false;
    currentChat.value = { id: '737' };
  });

  it('does not abrir o fluxo de pergunta quando captain_tasks esta desabilitado', async () => {
    const { execute } = useCopilotReply();

    await execute('ask_conversation');
    await nextTick();

    expect(mockAskConversation).not.toHaveBeenCalled();
    expect(mockProcessEvent).not.toHaveBeenCalled();
  });

  it('abre o editor inline para perguntar sobre a conversa', async () => {
    captainTasksEnabled.value = true;
    const { execute, showEditor, generatedContent, isButtonDisabled } =
      useCopilotReply();

    await execute('ask_conversation');
    await nextTick();

    expect(showEditor.value).toBe(true);
    expect(generatedContent.value).toBe('');
    expect(isButtonDisabled.value).toBe(true);
  });

  it('usa askConversation no primeiro envio e followUp nas refinacoes', async () => {
    captainTasksEnabled.value = true;
    mockAskConversation.mockResolvedValue({
      message: 'A ultima mensagem do cliente foi um teste.',
      followUpContext: {
        event_name: 'ask_conversation',
        original_context: 'contexto',
        last_response: 'A ultima mensagem do cliente foi um teste.',
        conversation_history: [],
      },
    });
    mockFollowUp.mockResolvedValue({
      message: 'Resposta refinada',
      followUpContext: {
        event_name: 'ask_conversation',
        original_context: 'contexto',
        last_response: 'Resposta refinada',
        conversation_history: [],
      },
    });

    const { execute, sendFollowUp, generatedContent, followUpContext } =
      useCopilotReply();

    await execute('ask_conversation');
    await sendFollowUp('Qual foi a ultima mensagem do cliente?');

    expect(mockAskConversation).toHaveBeenCalledWith({
      message: 'Qual foi a ultima mensagem do cliente?',
      signal: expect.any(AbortSignal),
    });
    expect(generatedContent.value).toBe(
      'A ultima mensagem do cliente foi um teste.'
    );
    expect(followUpContext.value?.event_name).toBe('ask_conversation');

    await sendFollowUp('Agora resuma em uma frase.');

    expect(mockFollowUp).toHaveBeenCalledWith({
      followUpContext: expect.objectContaining({
        event_name: 'ask_conversation',
      }),
      message: 'Agora resuma em uma frase.',
      signal: expect.any(AbortSignal),
    });
  });
});
