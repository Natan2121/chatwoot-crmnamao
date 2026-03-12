<script setup>
import { computed } from 'vue';
import Icon from 'next/icon/Icon.vue';
import { useI18n } from 'vue-i18n';
import { useMessageContext } from './provider.js';
import { hasOneDayPassed } from 'shared/helpers/timeHelper';
import { ORIENTATION, MESSAGE_STATUS } from './constants';

defineProps({
  error: { type: String, required: true },
});

const emit = defineEmits(['retry']);

const {
  orientation,
  status,
  createdAt,
  content,
  attachments,
  isWhatsAppLayout,
} = useMessageContext();

const { t } = useI18n();

const canRetry = computed(() => {
  const hasContent = content.value !== null;
  const hasAttachments = attachments.value && attachments.value.length > 0;
  return !hasOneDayPassed(createdAt.value) && (hasContent || hasAttachments);
});

const iconButtonClass = computed(() => {
  return isWhatsAppLayout.value
    ? 'rounded-full bg-[#fce8e6] text-[#b42318] hover:bg-[#f9d7d3]'
    : 'bg-n-alpha-2 rounded-md';
});

const tooltipClass = computed(() => {
  return isWhatsAppLayout.value
    ? 'bg-white border-white/80 text-[#111b21] shadow-[0_8px_30px_rgba(11,20,26,0.18)]'
    : 'bg-n-alpha-3 border-n-strong text-n-slate-12';
});
</script>

<template>
  <div
    class="flex items-center gap-1.5 text-xs"
    :class="isWhatsAppLayout ? 'text-[#b42318]' : 'text-n-ruby-11'"
  >
    <span>{{ t('CHAT_LIST.FAILED_TO_SEND') }}</span>
    <div class="relative group">
      <div
        class="size-5 grid place-content-center cursor-pointer transition-colors"
        :class="iconButtonClass"
      >
        <Icon
          icon="i-lucide-alert-triangle"
          class="size-[14px]"
          :class="isWhatsAppLayout ? 'text-[#b42318]' : 'text-n-ruby-11'"
        />
      </div>
      <div
        class="absolute bottom-6 w-52 break-all rounded-xl border px-4 py-3 text-xs opacity-0 invisible transition-all group-hover:visible group-hover:opacity-100"
        :class="[
          tooltipClass,
          {
            'ltr:left-0 rtl:right-0': orientation === ORIENTATION.LEFT,
            'ltr:right-0 rtl:left-0': orientation === ORIENTATION.RIGHT,
          },
        ]"
      >
        {{ error }}
      </div>
    </div>
    <button
      v-if="canRetry"
      type="button"
      :disabled="status !== MESSAGE_STATUS.FAILED"
      class="size-5 grid place-content-center cursor-pointer border-0 transition-colors"
      :class="iconButtonClass"
      @click="emit('retry')"
    >
      <Icon
        icon="i-lucide-refresh-ccw"
        class="size-[14px]"
        :class="isWhatsAppLayout ? 'text-[#b42318]' : 'text-n-ruby-11'"
      />
    </button>
  </div>
</template>
