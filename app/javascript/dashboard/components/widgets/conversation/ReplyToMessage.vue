<script setup>
import MessagePreview from 'dashboard/components/widgets/conversation/MessagePreview.vue';
import Button from 'dashboard/components-next/button/Button.vue';

defineProps({
  message: {
    type: Object,
    required: true,
  },
  isWhatsAppLayout: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['dismiss']);
</script>

<template>
  <div
    class="reply-editor mt-2 flex items-center gap-1.5 text-xs tracking-wide"
    :class="
      isWhatsAppLayout
        ? '-mx-1 rounded-2xl border-l-4 border-[#25d366] bg-[#f0f2f5] px-3 py-2 text-[#54656f]'
        : 'bg-n-slate-9/10 rounded-md py-1 pl-2 pr-1 -mx-2'
    "
  >
    <fluent-icon
      class="flex-shrink-0 icon"
      :class="isWhatsAppLayout ? 'text-[#25d366]' : ''"
      icon="arrow-reply"
      size="14"
    />
    <div class="flex-grow gap-1 mt-px text-xs truncate">
      {{ $t('CONVERSATION.REPLYBOX.REPLYING_TO') }}
      <MessagePreview
        :message="message"
        :show-message-type="false"
        :default-empty-message="$t('CONVERSATION.REPLY_MESSAGE_NOT_FOUND')"
        class="inline"
      />
    </div>
    <Button
      v-tooltip="$t('CONVERSATION.REPLYBOX.DISMISS_REPLY')"
      ghost
      xs
      slate
      icon="i-lucide-x"
      @click.stop="emit('dismiss')"
    />
  </div>
</template>

<style lang="scss">
// TODO: Remove this
// override for dashboard/assets/scss/widgets/_reply-box.scss
.reply-editor {
  .icon {
    margin-right: 0px !important;
  }
}
</style>
