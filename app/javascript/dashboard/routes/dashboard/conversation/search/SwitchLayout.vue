<script>
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    NextButton,
  },
  props: {
    isOnExpandedLayout: {
      type: Boolean,
      default: false,
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['toggle'],
  computed: {
    buttonClasses() {
      if (!this.isWhatsAppLayout) {
        return 'flex-shrink-0 rtl:rotate-180 ltr:rotate-0 md:inline-flex hidden';
      }

      return [
        'flex-shrink-0 rtl:rotate-180 ltr:rotate-0 md:inline-flex hidden',
        '!rounded-full !border !border-[#d1d7db] !bg-white !text-[#54656f]',
        'hover:!bg-[#f5f6f6] hover:!text-[#111b21]',
        'shadow-[0_1px_2px_rgba(11,20,26,0.08)]',
      ];
    },
  },
  methods: {
    toggle() {
      this.$emit('toggle');
    },
  },
};
</script>

<template>
  <NextButton
    v-tooltip.left="$t('CONVERSATION.SWITCH_VIEW_LAYOUT')"
    :icon="
      isOnExpandedLayout
        ? 'i-lucide-arrow-left-to-line'
        : 'i-lucide-arrow-right-to-line'
    "
    slate
    xs
    faded
    :class="buttonClasses"
    @click="toggle"
  />
</template>
