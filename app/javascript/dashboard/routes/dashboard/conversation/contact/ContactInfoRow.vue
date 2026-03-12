<script>
import { useAlert } from 'dashboard/composables';
import EmojiOrIcon from 'shared/components/EmojiOrIcon.vue';
import { copyTextToClipboard } from 'shared/helpers/clipboard';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    EmojiOrIcon,
    NextButton,
  },
  props: {
    href: {
      type: String,
      default: '',
    },
    title: {
      type: String,
      default: '',
    },
    icon: {
      type: String,
      required: true,
    },
    emoji: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      default: '',
    },
    showCopy: {
      type: Boolean,
      default: false,
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  methods: {
    async onCopy(e) {
      e.preventDefault();
      await copyTextToClipboard(this.value);
      useAlert(this.$t('CONTACT_PANEL.COPY_SUCCESSFUL'));
    },
  },
};
</script>

<template>
  <div
    class="contact-info-row"
    :class="
      isWhatsAppLayout
        ? 'contact-info-row--whatsapp'
        : 'w-full h-5 ltr:-ml-1 rtl:-mr-1'
    "
  >
    <a
      v-if="href"
      :href="href"
      class="flex items-center gap-2 text-n-slate-11"
      :class="
        isWhatsAppLayout
          ? 'contact-info-row__content contact-info-row__content--whatsapp'
          : 'hover:underline'
      "
    >
      <EmojiOrIcon
        :icon="icon"
        :emoji="emoji"
        icon-size="14"
        class="flex-shrink-0"
        :class="isWhatsAppLayout ? 'mt-0.5' : 'ltr:ml-1 rtl:mr-1'"
      />
      <div class="flex-1 min-w-0">
        <span
          v-if="isWhatsAppLayout && title"
          class="block mb-0.5 text-[11px] font-medium uppercase tracking-[0.04em] text-[#667781]"
        >
          {{ title }}
        </span>
        <span
          v-if="value"
          class="overflow-hidden text-sm text-ellipsis"
          :class="
            isWhatsAppLayout
              ? 'block whitespace-normal break-words leading-5 text-[#111b21]'
              : 'whitespace-nowrap'
          "
          :title="value"
        >
          {{ value }}
        </span>
        <span v-else class="text-sm text-n-slate-11">
          {{ $t('CONTACT_PANEL.NOT_AVAILABLE') }}
        </span>
      </div>
      <NextButton
        v-if="showCopy"
        ghost
        xs
        slate
        class="contact-info-row__copy"
        :class="isWhatsAppLayout ? '' : 'ltr:-ml-1 rtl:-mr-1'"
        icon="i-lucide-clipboard"
        @click="onCopy"
      />
    </a>

    <div
      v-else
      class="flex items-center gap-2 text-n-slate-11"
      :class="
        isWhatsAppLayout
          ? 'contact-info-row__content contact-info-row__content--whatsapp'
          : ''
      "
    >
      <EmojiOrIcon
        :icon="icon"
        :emoji="emoji"
        icon-size="14"
        class="flex-shrink-0"
        :class="isWhatsAppLayout ? 'mt-0.5' : 'ltr:ml-1 rtl:mr-1'"
      />
      <div class="flex-1 min-w-0">
        <span
          v-if="isWhatsAppLayout && title"
          class="block mb-0.5 text-[11px] font-medium uppercase tracking-[0.04em] text-[#667781]"
        >
          {{ title }}
        </span>
        <span
          v-if="value"
          v-dompurify-html="value"
          class="overflow-hidden text-sm text-ellipsis"
          :class="
            isWhatsAppLayout
              ? 'block whitespace-normal break-words leading-5 text-[#111b21]'
              : 'whitespace-nowrap'
          "
        />
        <span v-else class="text-sm text-n-slate-11">
          {{ $t('CONTACT_PANEL.NOT_AVAILABLE') }}
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.contact-info-row--whatsapp {
  @apply w-full;
}

.contact-info-row__content--whatsapp {
  @apply min-h-[3.5rem] rounded-2xl border border-[#e3e6e8] bg-[#f7f8fa] px-3 py-2 no-underline;
}

.contact-info-row--whatsapp {
  :deep(.contact-info-row__copy button) {
    @apply rounded-full border-0 text-[#54656f];
    background-color: #ffffff;
  }

  :deep(.contact-info-row__copy button:hover) {
    background-color: #f0f2f5;
  }
}
</style>
