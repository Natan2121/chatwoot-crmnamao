<script setup>
import { computed } from 'vue';

import MessageMeta from '../MessageMeta.vue';

import { emitter } from 'shared/helpers/mitt';
import { useMessageContext } from '../provider.js';
import { useI18n } from 'vue-i18n';

import MessageFormatter from 'shared/helpers/MessageFormatter.js';
import { BUS_EVENTS } from 'shared/constants/busEvents';
import { MESSAGE_VARIANTS, ORIENTATION } from '../constants';

const props = defineProps({
  hideMeta: { type: Boolean, default: false },
});

const {
  variant,
  orientation,
  inReplyTo,
  isWhatsAppLayout,
  shouldGroupWithNext,
  additionalAttributes,
} = useMessageContext();
const { t } = useI18n();

const varaintBaseMap = {
  [MESSAGE_VARIANTS.AGENT]: 'bg-n-solid-blue text-n-slate-12',
  [MESSAGE_VARIANTS.PRIVATE]:
    'bg-n-solid-amber text-n-amber-12 [&_.prosemirror-mention-node]:font-semibold',
  [MESSAGE_VARIANTS.USER]: 'bg-n-slate-4 text-n-slate-12',
  [MESSAGE_VARIANTS.ACTIVITY]: 'bg-n-alpha-1 text-n-slate-11 text-sm',
  [MESSAGE_VARIANTS.BOT]: 'bg-n-solid-iris text-n-slate-12',
  [MESSAGE_VARIANTS.TEMPLATE]: 'bg-n-solid-iris text-n-slate-12',
  [MESSAGE_VARIANTS.ERROR]: 'bg-n-ruby-4 text-n-ruby-12',
  [MESSAGE_VARIANTS.EMAIL]: 'w-full',
  [MESSAGE_VARIANTS.UNSUPPORTED]:
    'bg-n-solid-amber/70 border border-dashed border-n-amber-12 text-n-amber-12',
};

const whatsAppVariantBaseMap = {
  [MESSAGE_VARIANTS.AGENT]:
    'bg-[#d9fdd3] text-[#111b21] shadow-[0_1px_0_rgba(11,20,26,0.13)]',
  [MESSAGE_VARIANTS.PRIVATE]:
    'bg-[#fff3c4] text-[#5c4b14] shadow-[0_1px_0_rgba(11,20,26,0.08)]',
  [MESSAGE_VARIANTS.USER]:
    'bg-white text-[#111b21] shadow-[0_1px_0_rgba(11,20,26,0.13)]',
  [MESSAGE_VARIANTS.ACTIVITY]: 'bg-white/70 text-[#54656f] text-sm',
  [MESSAGE_VARIANTS.BOT]:
    'bg-[#d9fdd3] text-[#111b21] shadow-[0_1px_0_rgba(11,20,26,0.13)]',
  [MESSAGE_VARIANTS.TEMPLATE]:
    'bg-[#d9fdd3] text-[#111b21] shadow-[0_1px_0_rgba(11,20,26,0.13)]',
  [MESSAGE_VARIANTS.ERROR]:
    'bg-[#ffe5e5] text-[#7a1515] shadow-[0_1px_0_rgba(11,20,26,0.08)]',
  [MESSAGE_VARIANTS.EMAIL]: 'w-full',
  [MESSAGE_VARIANTS.UNSUPPORTED]:
    'bg-[#fff3c4] border border-dashed border-[#c6ab37] text-[#5c4b14]',
};

const orientationMap = {
  [ORIENTATION.LEFT]:
    'left-bubble rounded-xl ltr:rounded-bl-sm rtl:rounded-br-sm',
  [ORIENTATION.RIGHT]:
    'right-bubble rounded-xl ltr:rounded-br-sm rtl:rounded-bl-sm',
  [ORIENTATION.CENTER]: 'rounded-md',
};

const whatsAppOrientationMap = {
  [ORIENTATION.LEFT]:
    'left-bubble rounded-2xl ltr:rounded-tl-md rtl:rounded-tr-md',
  [ORIENTATION.RIGHT]:
    'right-bubble rounded-2xl ltr:rounded-tr-md rtl:rounded-tl-md',
  [ORIENTATION.CENTER]: 'rounded-2xl',
};

const flexOrientationClass = computed(() => {
  const map = {
    [ORIENTATION.LEFT]: 'justify-start',
    [ORIENTATION.RIGHT]: 'justify-end',
    [ORIENTATION.CENTER]: 'justify-center',
  };

  return map[orientation.value];
});

const isScheduledMessage = computed(
  () => !!additionalAttributes.value?.scheduledMessageId
);

const scheduledMessageClass = computed(() => {
  if (!isScheduledMessage.value) return '';
  if (variant.value === MESSAGE_VARIANTS.AGENT) return 'bg-n-solid-iris';
  return '';
});

const messageClass = computed(() => {
  const variantClassMap = isWhatsAppLayout.value
    ? whatsAppVariantBaseMap
    : varaintBaseMap;
  const orientationClassMap = isWhatsAppLayout.value
    ? whatsAppOrientationMap
    : orientationMap;
  const classToApply = [variantClassMap[variant.value]];

  if (variant.value !== MESSAGE_VARIANTS.ACTIVITY) {
    classToApply.push(orientationClassMap[orientation.value]);
  } else {
    classToApply.push('rounded-lg');
  }

  if (scheduledMessageClass.value) {
    classToApply.push(scheduledMessageClass.value);
  }

  return classToApply;
});

const scrollToMessage = () => {
  emitter.emit(BUS_EVENTS.SCROLL_TO_MESSAGE, {
    messageId: inReplyTo.value.id,
  });
};

const shouldShowMeta = computed(
  () =>
    !props.hideMeta &&
    !shouldGroupWithNext.value &&
    variant.value !== MESSAGE_VARIANTS.ACTIVITY
);

const bubbleWidthClass = computed(() => {
  if (variant.value === MESSAGE_VARIANTS.EMAIL) {
    return '';
  }

  return isWhatsAppLayout.value ? 'max-w-[78%] w-fit min-w-0' : 'max-w-lg';
});

const replyToPreview = computed(() => {
  if (!inReplyTo) return '';

  const { content, attachments } = inReplyTo.value;

  if (content) return new MessageFormatter(content).formattedMessage;
  if (attachments?.length) {
    const firstAttachment = attachments[0];
    const fileType = firstAttachment.fileType ?? firstAttachment.file_type;

    return t(`CHAT_LIST.ATTACHMENTS.${fileType}.CONTENT`);
  }

  return t('CONVERSATION.REPLY_MESSAGE_NOT_FOUND');
});
</script>

<template>
  <div class="text-sm" :class="[messageClass, bubbleWidthClass]">
    <div
      v-if="inReplyTo"
      class="p-2 -mx-1 mb-2 cursor-pointer"
      :class="
        isWhatsAppLayout
          ? 'rounded-xl border-l-[3px] border-[#25d366] bg-black/5'
          : 'rounded-lg bg-n-alpha-black1'
      "
      @click="scrollToMessage"
    >
      <div
        v-dompurify-html="replyToPreview"
        class="prose prose-bubble line-clamp-2"
        :class="isWhatsAppLayout ? 'text-[#54656f]' : ''"
      />
    </div>
    <slot />
    <MessageMeta
      v-if="shouldShowMeta"
      :class="[
        flexOrientationClass,
        variant === MESSAGE_VARIANTS.EMAIL ? 'px-3 pb-3' : '',
        isWhatsAppLayout
          ? variant === MESSAGE_VARIANTS.PRIVATE
            ? 'text-[#8e7a32]'
            : 'text-[#667781]'
          : variant === MESSAGE_VARIANTS.PRIVATE
            ? 'text-n-amber-12/50'
            : 'text-n-slate-11',
      ]"
      class="mt-2"
    />
  </div>
</template>
