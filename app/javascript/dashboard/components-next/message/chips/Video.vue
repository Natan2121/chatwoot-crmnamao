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

const showGallery = ref(false);
const hasError = ref(false);

const { filteredCurrentChatAttachments, isWhatsAppLayout } =
  useMessageContext();

const onError = () => {
  hasError.value = true;
};
</script>

<template>
  <div
    class="overflow-hidden contain-content cursor-pointer relative group"
    :class="
      isWhatsAppLayout
        ? 'h-[104px] w-[104px] rounded-[18px] border border-white/60 shadow-[0_1px_2px_rgba(11,20,26,0.12)]'
        : 'size-[72px] rounded-xl'
    "
    @click="showGallery = true"
  >
    <div
      v-if="hasError"
      class="flex h-full w-full flex-col items-center justify-center gap-1 text-center text-xs text-n-slate-11"
      :class="
        isWhatsAppLayout
          ? 'rounded-[18px] bg-white/85'
          : 'rounded-xl bg-n-alpha-1'
      "
    >
      <Icon icon="i-lucide-circle-off" class="text-n-slate-11" />
      {{ $t('COMPONENTS.MEDIA.LOADING_FAILED') }}
    </div>
    <video
      v-else
      :src="attachment.dataUrl"
      class="w-full h-full object-cover"
      muted
      playsInline
      @error="onError"
    />
    <div
      v-if="!hasError"
      class="absolute w-full h-full inset-0 p-1 flex items-center justify-center"
    >
      <div
        class="overflow-hidden rounded-full backdrop-blur-sm shadow-[0_5px_15px_rgba(0,0,0,0.4)]"
        :class="
          isWhatsAppLayout
            ? 'flex h-9 w-9 items-center justify-center bg-white/80'
            : 'size-7 bg-n-slate-1/60'
        "
      >
        <Icon
          icon="i-teenyicons-play-small-solid"
          class="backdrop-blur"
          :class="
            isWhatsAppLayout
              ? 'size-8 text-[#0b141a]/80'
              : 'size-7 text-n-slate-12/80'
          "
        />
      </div>
    </div>
    <div
      v-if="isWhatsAppLayout && !hasError"
      class="pointer-events-none absolute inset-x-0 bottom-0 h-10 bg-gradient-to-t from-black/25 to-transparent"
    />
  </div>
  <GalleryView
    v-if="showGallery"
    v-model:show="showGallery"
    :is-whats-app-layout="isWhatsAppLayout"
    :attachment="useSnakeCase(attachment)"
    :all-attachments="filteredCurrentChatAttachments"
    @error="onError"
    @close="() => (showGallery = false)"
  />
</template>
