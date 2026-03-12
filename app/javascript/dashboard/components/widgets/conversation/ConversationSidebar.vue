<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';
import ContactPanel from 'dashboard/routes/dashboard/conversation/ContactPanel.vue';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { useWindowSize } from '@vueuse/core';
import { vOnClickOutside } from '@vueuse/components';
import wootConstants from 'dashboard/constants/globals';
import { shouldUseWhatsAppConversationLayout } from 'dashboard/helper/conversationAppearance';

const props = defineProps({
  currentChat: {
    required: true,
    type: Object,
  },
});

const { uiSettings, updateUISettings } = useUISettings();
const { width: windowWidth } = useWindowSize();
const store = useStore();

const activeTab = computed(() => {
  const { is_contact_sidebar_open: isContactSidebarOpen } = uiSettings.value;

  if (isContactSidebarOpen) {
    return 0;
  }
  return null;
});

const isSmallScreen = computed(
  () => windowWidth.value < wootConstants.SMALL_SCREEN_BREAKPOINT
);

const currentInbox = computed(() => {
  return store.getters['inboxes/getInbox'](props.currentChat?.inbox_id);
});

const isWhatsAppLayout = computed(() => {
  return shouldUseWhatsAppConversationLayout(
    uiSettings.value,
    currentInbox.value
  );
});

const closeContactPanel = () => {
  if (isSmallScreen.value && uiSettings.value?.is_contact_sidebar_open) {
    updateUISettings({
      is_contact_sidebar_open: false,
      is_copilot_panel_open: false,
    });
  }
};
</script>

<template>
  <div
    v-on-click-outside="() => closeContactPanel()"
    class="conversation-sidebar h-full overflow-hidden flex flex-col fixed top-0 z-40 w-full max-w-sm transition-transform duration-300 ease-in-out ltr:right-0 rtl:left-0 ltr:border-l rtl:border-r shadow-lg md:shadow-none"
    :class="[
      isWhatsAppLayout
        ? 'conversation-sidebar--whatsapp bg-[#f7f8fa] border-[#d1d7db] md:w-[304px] md:min-w-[304px] 2xl:min-w-[332px] 2xl:w-[332px]'
        : 'bg-n-surface-2 border-n-weak md:w-[320px] md:min-w-[320px] 2xl:min-w-[360px] 2xl:w-[360px]',
      {
        'md:flex': activeTab === 0,
        'md:hidden': activeTab !== 0,
      },
    ]"
  >
    <div class="flex flex-1 overflow-auto">
      <ContactPanel
        v-show="activeTab === 0"
        :conversation-id="currentChat.id"
        :inbox-id="currentChat.inbox_id"
      />
    </div>
  </div>
</template>

<style scoped lang="scss">
.conversation-sidebar--whatsapp {
  box-shadow:
    -1px 0 0 rgba(209, 215, 219, 0.9),
    -12px 0 32px rgba(11, 20, 26, 0.08);

  @media (min-width: 768px) {
    border-top-left-radius: 1.5rem;
    border-bottom-left-radius: 1.5rem;
  }
}
</style>
