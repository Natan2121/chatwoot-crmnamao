<script>
import { MESSAGE_TYPE } from 'widget/helpers/constants';
import { useMessageFormatter } from 'shared/composables/useMessageFormatter';
import { ATTACHMENT_ICONS } from 'shared/constants/messages';
import Icon from 'next/icon/Icon.vue';

export default {
  name: 'MessagePreview',
  components: {
    Icon,
  },
  props: {
    message: {
      type: Object,
      required: true,
    },
    showMessageType: {
      type: Boolean,
      default: true,
    },
    defaultEmptyMessage: {
      type: String,
      default: '',
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  setup() {
    const { getPlainText } = useMessageFormatter();
    return {
      getPlainText,
    };
  },
  computed: {
    messageByAgent() {
      const { message_type: messageType } = this.message;
      return messageType === MESSAGE_TYPE.OUTGOING;
    },
    isMessageAnActivity() {
      const { message_type: messageType } = this.message;
      return messageType === MESSAGE_TYPE.ACTIVITY;
    },
    isMessagePrivate() {
      const { private: isPrivate } = this.message;
      return isPrivate;
    },
    parsedLastMessage() {
      const { content_attributes: contentAttributes } = this.message;
      const { email: { subject } = {} } = contentAttributes || {};
      return this.getPlainText(subject || this.message.content);
    },
    lastMessageFileType() {
      const [{ file_type: fileType } = {}] = this.message.attachments;
      return fileType;
    },
    attachmentIcon() {
      return ATTACHMENT_ICONS[this.lastMessageFileType];
    },
    attachmentMessageContent() {
      return `CHAT_LIST.ATTACHMENTS.${this.lastMessageFileType}.CONTENT`;
    },
    attachmentMessageLabel() {
      // eslint-disable-next-line @intlify/vue-i18n/no-dynamic-keys
      return this.$t(this.attachmentMessageContent);
    },
    isMessageSticker() {
      return this.message && this.message.content_type === 'sticker';
    },
    isFailedMessage() {
      return this.message?.status === 'failed';
    },
    shouldShowWhatsAppLeadingIcon() {
      return this.isWhatsAppLayout && this.showMessageType;
    },
    leadingIconName() {
      if (!this.shouldShowWhatsAppLeadingIcon) return '';

      if (this.isMessagePrivate) return 'i-lucide-lock';
      if (this.isMessageAnActivity) return 'i-lucide-info';
      if (this.isMessageSticker) return 'i-lucide-image';
      if (this.messageByAgent) {
        if (this.isFailedMessage) return 'i-lucide-alert-circle';

        const statusIconMap = {
          read: 'i-lucide-check-check',
          delivered: 'i-lucide-check-check',
          sent: 'i-lucide-check',
          progress: 'i-lucide-clock-3',
        };

        return statusIconMap[this.message?.status] || 'i-lucide-check';
      }

      if (this.isMessageSticker || this.message?.attachments?.length) {
        return 'i-lucide-paperclip';
      }

      return '';
    },
    leadingIconClass() {
      if (!this.shouldShowWhatsAppLeadingIcon) return '';

      if (this.isMessagePrivate || this.isMessageAnActivity) {
        return 'text-[#667781]';
      }

      if (this.messageByAgent) {
        if (this.message?.status === 'read') return 'text-[#53bdeb]';
        if (this.isFailedMessage) return 'text-[#b42318]';
        return 'text-[#667781]';
      }

      return 'text-[#667781]';
    },
    previewWrapperClass() {
      if (!this.isWhatsAppLayout) {
        return 'overflow-hidden text-ellipsis whitespace-nowrap';
      }

      return 'flex min-w-0 items-center gap-1.5 overflow-hidden whitespace-nowrap';
    },
    previewTextClass() {
      if (!this.isWhatsAppLayout) {
        return '';
      }

      return 'min-w-0 truncate text-[#667781]';
    },
    emptyMessageLabel() {
      return this.defaultEmptyMessage || this.$t('CHAT_LIST.NO_CONTENT');
    },
  },
};
</script>

<template>
  <div :class="previewWrapperClass">
    <Icon
      v-if="leadingIconName"
      class="size-3.5 flex-shrink-0"
      :class="leadingIconClass"
      :icon="leadingIconName"
    />
    <template v-if="showMessageType && !isWhatsAppLayout">
      <fluent-icon
        v-if="isMessagePrivate"
        size="16"
        class="-mt-0.5 align-middle text-n-slate-11 inline-block"
        icon="lock-closed"
      />
      <fluent-icon
        v-else-if="messageByAgent"
        size="16"
        class="-mt-0.5 align-middle text-n-slate-11 inline-block"
        icon="arrow-reply"
      />
      <fluent-icon
        v-else-if="isMessageAnActivity"
        size="16"
        class="-mt-0.5 align-middle text-n-slate-11 inline-block"
        icon="info"
      />
    </template>
    <span v-if="message.content && isMessageSticker">
      <fluent-icon
        v-if="!isWhatsAppLayout"
        size="16"
        class="-mt-0.5 align-middle inline-block text-n-slate-11"
        icon="image"
      />
      <span :class="previewTextClass">
        {{ $t('CHAT_LIST.ATTACHMENTS.image.CONTENT') }}
      </span>
    </span>
    <span v-else-if="message.content" :class="previewTextClass">
      {{ parsedLastMessage }}
    </span>
    <span v-else-if="message.attachments" :class="previewTextClass">
      <fluent-icon
        v-if="attachmentIcon && showMessageType && !isWhatsAppLayout"
        size="16"
        class="-mt-0.5 align-middle inline-block text-n-slate-11"
        :icon="attachmentIcon"
      />
      {{ attachmentMessageLabel }}
    </span>
    <span v-else :class="previewTextClass">
      {{ emptyMessageLabel }}
    </span>
  </div>
</template>
