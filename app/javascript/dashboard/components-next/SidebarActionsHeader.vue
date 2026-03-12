<script setup>
import Button from './button/Button.vue';
defineProps({
  title: {
    type: String,
    required: true,
  },
  buttons: {
    type: Array,
    default: () => [],
  },
  isWhatsAppLayout: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['click', 'close']);

const handleButtonClick = button => {
  emit('click', button.key);
};
</script>

<template>
  <div
    class="sidebar-actions-header flex items-center justify-between px-4 py-2 border-b h-12"
    :class="
      isWhatsAppLayout
        ? 'sidebar-actions-header--whatsapp border-[#d1d7db] bg-[#f0f2f5]'
        : 'border-n-weak'
    "
  >
    <div class="flex items-center justify-between gap-2 flex-1">
      <span
        class="font-medium text-sm"
        :class="isWhatsAppLayout ? 'text-[#111b21]' : 'text-n-slate-12'"
      >
        {{ title }}
      </span>
      <div class="flex items-center">
        <Button
          v-for="button in buttons"
          :key="button.key"
          v-tooltip="button.tooltip"
          :icon="button.icon"
          ghost
          sm
          @click="handleButtonClick(button)"
        />
        <Button
          v-tooltip="$t('GENERAL.CLOSE')"
          icon="i-lucide-x"
          ghost
          sm
          @click="$emit('close')"
        />
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.sidebar-actions-header--whatsapp {
  :deep(button) {
    @apply rounded-full border-0 text-[#54656f];
    background-color: rgba(255, 255, 255, 0.92);
    box-shadow: 0 1px 2px rgba(11, 20, 26, 0.08);
  }

  :deep(button:hover) {
    background-color: #ffffff;
  }
}
</style>
