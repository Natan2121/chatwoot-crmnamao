<script setup>
import { computed } from 'vue';
import { useMessageContext } from '../provider.js';
import { useInbox } from 'dashboard/composables/useInbox';
import { useI18n } from 'vue-i18n';
import Icon from 'next/icon/Icon.vue';
import BaseBubble from './Base.vue';

const { inboxId, isWhatsAppLayout } = useMessageContext();
const { t } = useI18n();

const { isAFacebookInbox, isAnInstagramChannel, isATiktokChannel } = useInbox(
  inboxId.value
);

const unsupportedMessageKey = computed(() => {
  if (isAFacebookInbox.value)
    return 'CONVERSATION.UNSUPPORTED_MESSAGE_FACEBOOK';
  if (isAnInstagramChannel.value)
    return 'CONVERSATION.UNSUPPORTED_MESSAGE_INSTAGRAM';
  if (isATiktokChannel.value) return 'CONVERSATION.UNSUPPORTED_MESSAGE_TIKTOK';
  return 'CONVERSATION.UNSUPPORTED_MESSAGE';
});

const unsupportedMessageLabel = computed(() => {
  // eslint-disable-next-line @intlify/vue-i18n/no-dynamic-keys
  return t(unsupportedMessageKey.value);
});
</script>

<template>
  <BaseBubble
    class="px-4 py-3 text-sm"
    data-bubble-name="unsupported"
    :class="isWhatsAppLayout ? 'max-w-[20rem]' : ''"
  >
    <div class="flex items-start gap-2">
      <span
        class="mt-0.5 flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full"
        :class="
          isWhatsAppLayout
            ? 'bg-[#f0f2f5] text-[#54656f]'
            : 'bg-n-alpha-2 text-n-slate-11'
        "
      >
        <Icon icon="i-lucide-ban" class="size-3.5" />
      </span>
      <span class="leading-5">
        {{ unsupportedMessageLabel }}
      </span>
    </div>
  </BaseBubble>
</template>
