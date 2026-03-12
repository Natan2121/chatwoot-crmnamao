<script>
import { mapGetters } from 'vuex';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { shouldUseWhatsAppConversationLayout } from 'dashboard/helper/conversationAppearance';
import ConversationHeader from './ConversationHeader.vue';
import DashboardAppFrame from '../DashboardApp/Frame.vue';
import EmptyState from './EmptyState/EmptyState.vue';
import MessagesView from './MessagesView.vue';

export default {
  components: {
    ConversationHeader,
    DashboardAppFrame,
    EmptyState,
    MessagesView,
  },
  props: {
    inboxId: {
      type: [Number, String],
      default: '',
      required: false,
    },
    isInboxView: {
      type: Boolean,
      default: false,
    },
    isContactPanelOpen: {
      type: Boolean,
      default: true,
    },
    isOnExpandedLayout: {
      type: Boolean,
      default: true,
    },
  },
  setup() {
    const { uiSettings } = useUISettings();

    return {
      uiSettings,
    };
  },
  data() {
    return { activeIndex: 0 };
  },
  computed: {
    ...mapGetters({
      currentChat: 'getSelectedChat',
      dashboardApps: 'dashboardApps/getRecords',
    }),
    currentInbox() {
      if (!this.currentChat?.inbox_id) {
        return null;
      }

      return this.$store.getters['inboxes/getInbox'](this.currentChat.inbox_id);
    },
    conversationDashboardApps() {
      return this.dashboardApps.filter(app => !app.show_on_sidebar);
    },
    dashboardAppTabs() {
      return [
        {
          key: 'messages',
          index: 0,
          name: this.$t('CONVERSATION.DASHBOARD_APP_TAB_MESSAGES'),
        },
        ...this.conversationDashboardApps.map((dashboardApp, index) => ({
          key: `dashboard-${dashboardApp.id}`,
          index: index + 1,
          name: dashboardApp.title,
        })),
      ];
    },
    showContactPanel() {
      return this.isContactPanelOpen && this.currentChat.id;
    },
    isWhatsAppLayout() {
      return shouldUseWhatsAppConversationLayout(
        this.uiSettings,
        this.currentInbox
      );
    },
  },
  watch: {
    'currentChat.inbox_id': {
      immediate: true,
      handler(inboxId) {
        if (inboxId) {
          this.$store.dispatch('inboxAssignableAgents/fetch', [inboxId]);
        }
      },
    },
    'currentChat.id'() {
      this.fetchLabels();
      this.activeIndex = 0;
    },
  },
  mounted() {
    this.fetchLabels();
    this.$store.dispatch('dashboardApps/get');
  },
  methods: {
    fetchLabels() {
      if (!this.currentChat.id) {
        return;
      }
      this.$store.dispatch('conversationLabels/get', this.currentChat.id);
    },
    onDashboardAppTabChange(index) {
      this.activeIndex = index;
    },
  },
};
</script>

<template>
  <div
    class="conversation-details-wrap flex flex-col min-w-0 w-full relative overflow-hidden"
    :class="[
      isWhatsAppLayout
        ? 'conversation-details-wrap--whatsapp bg-[#efeae2]'
        : 'bg-n-surface-1',
      {
        'border-l rtl:border-l-0 rtl:border-r border-n-weak':
          !isOnExpandedLayout,
      },
    ]"
  >
    <ConversationHeader
      v-if="currentChat.id"
      :chat="currentChat"
      :show-back-button="isOnExpandedLayout && !isInboxView"
      :is-whats-app-layout="isWhatsAppLayout"
    />
    <woot-tabs
      v-if="conversationDashboardApps.length && currentChat.id"
      :index="activeIndex"
      :class="
        isWhatsAppLayout
          ? 'conversation-box-tabs conversation-box-tabs--whatsapp h-10 border-b border-[#d1d7db] bg-[#f0f2f5]'
          : 'h-10'
      "
      @change="onDashboardAppTabChange"
    >
      <woot-tabs-item
        v-for="tab in dashboardAppTabs"
        :key="tab.key"
        :index="tab.index"
        :name="tab.name"
        :show-badge="false"
        is-compact
      />
    </woot-tabs>
    <div
      v-show="!activeIndex"
      class="flex h-full min-h-0 m-0"
      :class="isWhatsAppLayout ? 'bg-[#efeae2]' : ''"
    >
      <MessagesView
        v-if="currentChat.id"
        :inbox-id="inboxId"
        :is-inbox-view="isInboxView"
      />
      <EmptyState
        v-if="!currentChat.id && !isInboxView"
        :is-on-expanded-layout="isOnExpandedLayout"
        :is-whats-app-layout="isWhatsAppLayout"
      />
      <slot />
    </div>
    <DashboardAppFrame
      v-for="(dashboardApp, index) in conversationDashboardApps"
      v-show="activeIndex - 1 === index"
      :key="currentChat.id + '-' + dashboardApp.id"
      :is-visible="activeIndex - 1 === index"
      :config="conversationDashboardApps[index].content"
      :position="index"
      :current-chat="currentChat"
    />
  </div>
</template>

<style scoped lang="scss">
.conversation-details-wrap--whatsapp {
  background-image: radial-gradient(
      circle at 24px 24px,
      rgba(255, 255, 255, 0.24) 0,
      rgba(255, 255, 255, 0.24) 2px,
      transparent 2.2px
    ),
    radial-gradient(
      circle at 0 0,
      rgba(17, 27, 33, 0.03) 0,
      rgba(17, 27, 33, 0.03) 1.5px,
      transparent 1.8px
    ),
    linear-gradient(
      180deg,
      rgba(255, 255, 255, 0.26),
      rgba(255, 255, 255, 0.04)
    );
  background-size:
    48px 48px,
    32px 32px,
    100% 100%;
  background-position: center;

  &::before {
    content: '';
    @apply absolute inset-0 pointer-events-none;
    background: linear-gradient(
      180deg,
      rgba(239, 234, 226, 0.08) 0%,
      rgba(239, 234, 226, 0.02) 20%,
      rgba(239, 234, 226, 0.22) 100%
    );
  }

  > * {
    position: relative;
    z-index: 1;
  }
}

.conversation-box-tabs--whatsapp {
  :deep(ul) {
    @apply gap-2 px-4 py-1;
  }

  :deep(li a) {
    @apply rounded-full border-0 px-3 py-1.5 text-[13px] font-medium text-[#54656f];
    background-color: rgba(255, 255, 255, 0.92);
  }

  :deep(li a:hover) {
    background-color: #ffffff;
  }

  :deep(li[aria-selected='true'] a),
  :deep(li.active a) {
    @apply text-[#111b21];
    background-color: #d9fdd3;
  }
}
</style>
