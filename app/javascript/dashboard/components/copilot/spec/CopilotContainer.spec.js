import { mount } from '@vue/test-utils';
import { defineComponent, h, ref } from 'vue';
import CopilotContainer from '../CopilotContainer.vue';
import { useStore, useMapGetter } from 'dashboard/composables/store';
import { useUISettings } from 'dashboard/composables/useUISettings';

vi.mock('dashboard/composables/store');
vi.mock('dashboard/composables/useUISettings');
vi.mock('@vueuse/core', () => ({
  useWindowSize: () => ({
    width: ref(1440),
  }),
}));
vi.mock('@vueuse/components', () => ({
  vOnClickOutside: {},
}));
vi.mock('dashboard/components-next/copilot/Copilot.vue', () => ({
  default: defineComponent({
    name: 'CopilotStub',
    render() {
      return h('div', 'Copilot pronto');
    },
  }),
}));

describe('CopilotContainer', () => {
  const mockStore = {
    dispatch: vi.fn(),
    getters: {
      'copilotMessages/getMessagesByThreadId': vi.fn(() => []),
    },
  };

  const uiSettings = ref({
    is_copilot_panel_open: true,
    preferred_captain_assistant_id: null,
  });

  const featureEnabled = ref(true);

  beforeEach(() => {
    vi.clearAllMocks();
    uiSettings.value = {
      is_copilot_panel_open: true,
      preferred_captain_assistant_id: null,
    };
    featureEnabled.value = true;

    useStore.mockReturnValue(mockStore);
    useUISettings.mockReturnValue({
      uiSettings,
      updateUISettings: vi.fn(),
    });
    useMapGetter.mockImplementation(getter => {
      const mockValues = {
        getCurrentUser: ref({ id: 7, name: 'Agente' }),
        'captainAssistants/getRecords': ref([{ id: 11, name: 'Copiloto CRM' }]),
        'captainAssistants/getUIFlags': ref({ fetchingList: false }),
        getCopilotAssistant: ref(null),
        getSelectedChat: ref({ id: 99 }),
        getCurrentAccountId: ref(2),
        'accounts/isFeatureEnabledonAccount': ref(() => featureEnabled.value),
      };

      return mockValues[getter];
    });
  });

  it('renderiza o painel quando a feature captain esta habilitada', () => {
    const wrapper = mount(CopilotContainer, {
      props: {
        conversationInboxType: 'Channel::Api',
      },
    });

    expect(wrapper.text()).toContain('Copilot pronto');
  });

  it('nao renderiza o painel quando a feature captain esta desabilitada', () => {
    featureEnabled.value = false;

    const wrapper = mount(CopilotContainer, {
      props: {
        conversationInboxType: 'Channel::Api',
      },
    });

    expect(wrapper.text()).not.toContain('Copilot pronto');
  });

  it('busca assistentes ao montar quando captain esta habilitado', () => {
    mount(CopilotContainer, {
      props: {
        conversationInboxType: 'Channel::Api',
      },
    });

    expect(mockStore.dispatch).toHaveBeenCalledWith('captainAssistants/get');
  });
});
