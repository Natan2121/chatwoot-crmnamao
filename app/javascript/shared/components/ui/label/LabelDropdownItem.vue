<script>
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    NextButton,
  },
  props: {
    title: {
      type: String,
      default: '',
    },
    color: {
      type: String,
      default: '',
    },
    selected: {
      type: Boolean,
      default: false,
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['selectLabel'],

  methods: {
    onClick() {
      this.$emit('selectLabel', this.title);
    },
  },
};
</script>

<template>
  <woot-dropdown-item>
    <NextButton
      slate
      ghost
      blue
      trailing-icon
      :icon="selected ? 'i-lucide-circle-check' : ''"
      class="w-full !px-2.5 justify-between"
      :class="[
        { '!flex-row': !selected },
        isWhatsAppLayout ? 'label-dropdown-item--whatsapp' : '',
      ]"
      @click="onClick"
    >
      <div class="flex items-center min-w-0 gap-2">
        <div
          v-if="color"
          class="size-3 flex-shrink-0 rounded-full outline outline-1 outline-n-weak"
          :style="{ backgroundColor: color }"
        />
        <span
          class="overflow-hidden text-ellipsis whitespace-nowrap leading-[1.1]"
          :title="title"
        >
          {{ title }}
        </span>
      </div>
    </NextButton>
  </woot-dropdown-item>
</template>

<style scoped lang="scss">
:deep(.label-dropdown-item--whatsapp) {
  @apply rounded-2xl border border-transparent py-2;
}

:deep(.label-dropdown-item--whatsapp:hover) {
  background-color: #f7f8fa;
}
</style>
