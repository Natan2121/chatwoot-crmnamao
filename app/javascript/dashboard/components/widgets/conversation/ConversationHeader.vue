<script setup>
import { computed, ref } from 'vue';
import { useRoute } from 'vue-router';
import { useStore } from 'vuex';
import { useElementSize } from '@vueuse/core';
import BackButton from '../BackButton.vue';
import InboxName from '../InboxName.vue';
import MoreActions from './MoreActions.vue';
import Avatar from 'next/avatar/Avatar.vue';
import SLACardLabel from './components/SLACardLabel.vue';
import wootConstants from 'dashboard/constants/globals';
import { conversationListPageURL } from 'dashboard/helper/URLHelper';
import { snoozedReopenTime } from 'dashboard/helper/snoozeHelpers';
import { useInbox } from 'dashboard/composables/useInbox';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { shouldUseWhatsAppConversationLayout } from 'dashboard/helper/conversationAppearance';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  chat: {
    type: Object,
    default: () => ({}),
  },
  showBackButton: {
    type: Boolean,
    default: false,
  },
  isWhatsAppLayout: {
    type: Boolean,
    default: false,
  },
});

const { t } = useI18n();
const store = useStore();
const route = useRoute();
const conversationHeader = ref(null);
const { width } = useElementSize(conversationHeader);
const { isAWebWidgetInbox } = useInbox();
const { uiSettings } = useUISettings();

const currentChat = computed(() => store.getters.getSelectedChat);
const accountId = computed(() => store.getters.getCurrentAccountId);

const chatMetadata = computed(() => props.chat.meta);

const backButtonUrl = computed(() => {
  const {
    params: { inbox_id: inboxId, label, teamId, id: customViewId },
    name,
  } = route;

  const conversationTypeMap = {
    conversation_through_mentions: 'mention',
    conversation_through_unattended: 'unattended',
  };
  return conversationListPageURL({
    accountId: accountId.value,
    inboxId,
    label,
    teamId,
    conversationType: conversationTypeMap[name],
    customViewId,
  });
});

const isHMACVerified = computed(() => {
  if (!isAWebWidgetInbox.value) {
    return true;
  }
  return chatMetadata.value.hmac_verified;
});

const currentContact = computed(() =>
  store.getters['contacts/getContact'](props.chat.meta.sender.id)
);

const isSnoozed = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.SNOOZED
);

const snoozedDisplayText = computed(() => {
  const { snoozed_until: snoozedUntil } = currentChat.value;
  if (snoozedUntil) {
    return `${t('CONVERSATION.HEADER.SNOOZED_UNTIL')} ${snoozedReopenTime(snoozedUntil)}`;
  }
  return t('CONVERSATION.HEADER.SNOOZED_UNTIL_NEXT_REPLY');
});

const inbox = computed(() => {
  const { inbox_id: inboxId } = props.chat;
  return store.getters['inboxes/getInbox'](inboxId);
});

const useWhatsAppLayout = computed(() => {
  return (
    props.isWhatsAppLayout ||
    shouldUseWhatsAppConversationLayout(uiSettings.value, inbox.value)
  );
});

const hasMultipleInboxes = computed(
  () => store.getters['inboxes/getInboxes'].length > 1
);

const hasSlaPolicyId = computed(() => props.chat?.sla_policy_id);
</script>

<template>
  <div
    ref="conversationHeader"
    class="flex flex-1 w-full min-w-0 items-center justify-between"
    :class="
      useWhatsAppLayout
        ? 'gap-3 border-b border-[#d1d7db] bg-[#f0f2f5] px-4 py-3 h-16'
        : 'flex-col gap-3 xl:flex-row px-3 pt-3 pb-2 h-24 xl:h-12'
    "
  >
    <div
      class="flex items-center justify-start max-w-full min-w-0"
      :class="
        useWhatsAppLayout ? 'flex-1 w-auto' : 'w-full xl:w-auto xl:flex-1'
      "
    >
      <BackButton
        v-if="showBackButton"
        :back-url="backButtonUrl"
        class="ltr:mr-2 rtl:ml-2"
      />
      <Avatar
        :name="currentContact.name"
        :src="currentContact.thumbnail"
        :size="useWhatsAppLayout ? 40 : 32"
        :status="currentContact.availability_status"
        hide-offline-status
        rounded-full
      />
      <div
        class="flex min-w-0 flex-col items-start overflow-hidden ml-3 rtl:ml-0 rtl:mr-3"
      >
        <div class="flex flex-row items-center max-w-full gap-1 p-0 m-0">
          <span
            class="truncate leading-tight"
            :class="
              useWhatsAppLayout
                ? 'text-[15px] font-medium text-[#111b21]'
                : 'text-sm font-medium text-n-slate-12'
            "
          >
            {{ currentContact.name }}
          </span>
          <fluent-icon
            v-if="!isHMACVerified"
            v-tooltip="$t('CONVERSATION.UNVERIFIED_SESSION')"
            size="14"
            class="text-n-amber-10 my-0 mx-0 min-w-[14px] flex-shrink-0"
            icon="warning"
          />
        </div>

        <div
          class="flex items-center gap-2 overflow-hidden conversation--header--actions text-ellipsis whitespace-nowrap"
          :class="useWhatsAppLayout ? 'text-[12px] text-[#667781]' : 'text-xs'"
        >
          <InboxName v-if="hasMultipleInboxes" :inbox="inbox" class="!mx-0" />
          <span v-if="isSnoozed" class="font-medium text-n-amber-10">
            {{ snoozedDisplayText }}
          </span>
        </div>
      </div>
    </div>
    <div
      class="flex flex-row items-center gap-2 flex-shrink-0 header-actions-wrap"
      :class="
        useWhatsAppLayout
          ? 'justify-end w-auto'
          : 'justify-start xl:justify-end w-full xl:w-auto'
      "
    >
      <SLACardLabel
        v-if="hasSlaPolicyId"
        :chat="chat"
        show-extended-info
        :parent-width="width"
        class="hidden md:flex"
      />
      <MoreActions
        :conversation-id="currentChat.id"
        :is-whats-app-layout="useWhatsAppLayout"
      />
    </div>
  </div>
</template>

<style scoped lang="scss">
.header-actions-wrap {
  &.justify-end {
    :deep(button) {
      @apply rounded-full border-0 text-[#54656f];
      background-color: rgba(255, 255, 255, 0.92);
      box-shadow: 0 1px 2px rgba(11, 20, 26, 0.08);
    }

    :deep(button:hover) {
      background-color: #ffffff;
    }
  }
}
</style>
