<script setup>
import { ref } from 'vue';
import Icon from 'next/icon/Icon.vue';
import { useSnakeCase } from 'dashboard/composables/useTransformKeys';
import { useMessageContext } from '../provider.js';

import GalleryView from 'dashboard/components/widgets/conversation/components/GalleryView.vue';

defineProps({
  attachment: {
    type: Object,
    required: true,
  },
});
const hasError = ref(false);
const showGallery = ref(false);

const { filteredCurrentChatAttachments, isWhatsAppLayout } =
  useMessageContext();

const handleError = () => {
  hasError.value = true;
};
</script>

<template>
  <div
    class="overflow-hidden contain-content cursor-pointer relative"
    :class="
      isWhatsAppLayout
        ? 'h-[104px] w-[104px] rounded-[18px] border border-white/60 shadow-[0_1px_2px_rgba(11,20,26,0.12)]'
        : 'size-[72px] rounded-xl'
    "
    @click="showGallery = true"
  >
    <div
      v-if="hasError"
      class="flex flex-col items-center justify-center gap-1 text-xs text-center size-full text-n-slate-11"
      :class="
        isWhatsAppLayout ? 'rounded-2xl bg-white/80' : 'rounded-lg bg-n-alpha-1'
      "
    >
      <Icon icon="i-lucide-circle-off" class="text-n-slate-11" />
      {{ $t('COMPONENTS.MEDIA.LOADING_FAILED') }}
    </div>
    <img
      v-else
      class="object-cover w-full h-full skip-context-menu"
      :src="attachment.dataUrl"
      @error="handleError"
    />
    <div
      v-if="isWhatsAppLayout && !hasError"
      class="pointer-events-none absolute inset-x-0 bottom-0 h-10 bg-gradient-to-t from-black/20 to-transparent"
    />
  </div>
  <GalleryView
    v-if="showGallery"
    v-model:show="showGallery"
    :is-whats-app-layout="isWhatsAppLayout"
    :attachment="useSnakeCase(attachment)"
    :all-attachments="filteredCurrentChatAttachments"
    @error="handleError"
    @close="() => (showGallery = false)"
  />
</template>
