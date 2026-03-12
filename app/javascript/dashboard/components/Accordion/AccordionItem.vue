<script setup>
import EmojiOrIcon from 'shared/components/EmojiOrIcon.vue';
import { defineEmits } from 'vue';

defineProps({
  title: {
    type: String,
    required: true,
  },
  compact: {
    type: Boolean,
    default: false,
  },
  icon: {
    type: String,
    default: '',
  },
  emoji: {
    type: String,
    default: '',
  },
  isOpen: {
    type: Boolean,
    default: true,
  },
  isWhatsAppLayout: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['toggle']);

const onToggle = () => {
  emit('toggle');
};
</script>

<template>
  <div class="text-sm">
    <button
      class="flex items-center select-none w-full m-0 cursor-grab justify-between py-2 px-4 drag-handle"
      :class="[
        isWhatsAppLayout
          ? 'rounded-2xl bg-white outline outline-1 outline-[#dfe5e7] shadow-[0_1px_2px_rgba(17,27,33,0.06)]'
          : 'rounded-lg bg-n-slate-2 outline outline-1 outline-n-weak',
        { 'rounded-bl-none rounded-br-none': isOpen },
      ]"
      @click.stop="onToggle"
    >
      <div class="flex justify-between">
        <EmojiOrIcon class="inline-block w-5" :icon="icon" :emoji="emoji" />
        <h5
          class="text-sm mb-0 py-0 pr-2 pl-0"
          :class="isWhatsAppLayout ? 'text-[#111b21]' : 'text-n-slate-12'"
        >
          {{ title }}
        </h5>
      </div>
      <div class="flex flex-row">
        <slot name="button" />
        <div
          class="flex justify-end w-3 cursor-pointer"
          :class="isWhatsAppLayout ? 'text-[#00a884]' : 'text-n-blue-11'"
        >
          <fluent-icon v-if="isOpen" size="24" icon="subtract" type="solid" />
          <fluent-icon v-else size="24" icon="add" type="solid" />
        </div>
      </div>
    </button>
    <div
      v-if="isOpen"
      class="-mt-[-1px] border-t-0"
      :class="[
        isWhatsAppLayout
          ? 'rounded-br-2xl rounded-bl-2xl bg-white/95 outline outline-1 outline-[#dfe5e7]'
          : 'rounded-br-lg rounded-bl-lg outline outline-1 outline-n-weak',
        compact ? 'p-0' : 'px-2 py-4',
      ]"
    >
      <slot />
    </div>
  </div>
</template>
