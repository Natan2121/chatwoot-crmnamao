import { defineComponent, ref } from 'vue';
import { mount } from '@vue/test-utils';
import { useLabelSuggestions } from '../useLabelSuggestions';
import { useMapGetter, useStore } from 'dashboard/composables/store';
import { useAccount } from 'dashboard/composables/useAccount';
import TasksAPI from 'dashboard/api/captain/tasks';

vi.mock('dashboard/composables/store');
vi.mock('dashboard/composables/useAccount');
vi.mock('dashboard/api/captain/tasks');

describe('useLabelSuggestions', () => {
  const mockStore = {
    dispatch: vi.fn(),
  };

  const appIntegrations = ref([]);
  const currentChat = ref({ id: '737' });

  beforeEach(() => {
    vi.clearAllMocks();
    appIntegrations.value = [];
    currentChat.value = { id: '737' };

    useStore.mockReturnValue(mockStore);
    useMapGetter.mockImplementation(getter => {
      const mockValues = {
        'integrations/getAppIntegrations': appIntegrations,
        getSelectedChat: currentChat,
      };

      return mockValues[getter];
    });
    useAccount.mockReturnValue({
      isCloudFeatureEnabled: vi.fn().mockReturnValue(true),
    });
  });

  const mountComposable = () => {
    let composable;

    mount(
      defineComponent({
        setup() {
          composable = useLabelSuggestions();
          return {};
        },
        template: '<div />',
      })
    );

    return composable;
  };

  it('loads integrations before requesting label suggestions', async () => {
    mockStore.dispatch.mockImplementation(async action => {
      if (action === 'integrations/get') {
        appIntegrations.value = [
          {
            id: 'openai',
            hooks: [{ settings: { label_suggestion: true } }],
          },
        ];
      }
    });
    TasksAPI.labelSuggestion.mockResolvedValue({
      data: { message: 'qualificado, novo-lead' },
    });

    const { getLabelSuggestions, isLabelSuggestionFeatureEnabled } =
      mountComposable();

    const labels = await getLabelSuggestions();

    expect(mockStore.dispatch).toHaveBeenCalledWith('integrations/get');
    expect(TasksAPI.labelSuggestion).toHaveBeenCalledWith('737');
    expect(isLabelSuggestionFeatureEnabled.value).toBe(true);
    expect(labels).toEqual(['qualificado', 'novo-lead']);
  });

  it('does not call the API when label suggestion stays disabled', async () => {
    mockStore.dispatch.mockResolvedValue(undefined);

    const { getLabelSuggestions } = mountComposable();

    const labels = await getLabelSuggestions();

    expect(mockStore.dispatch).toHaveBeenCalledWith('integrations/get');
    expect(TasksAPI.labelSuggestion).not.toHaveBeenCalled();
    expect(labels).toEqual([]);
  });
});
