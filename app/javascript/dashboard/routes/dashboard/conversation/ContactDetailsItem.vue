<script>
export default {
  props: {
    title: { type: String, required: true },
    value: { type: [String, Number], default: '' },
    compact: { type: Boolean, default: false },
    isWhatsAppLayout: { type: Boolean, default: false },
  },
};
</script>

<template>
  <div
    class="overflow-auto"
    :class="[
      compact ? 'py-0 px-0' : 'py-3 px-4',
      isWhatsAppLayout ? 'contact-details-item--whatsapp' : '',
    ]"
  >
    <div class="items-center flex justify-between mb-1.5">
      <span
        class="text-sm font-medium"
        :class="isWhatsAppLayout ? 'text-[#54656f]' : 'text-n-slate-12'"
      >
        {{ title }}
      </span>
      <slot name="button" />
    </div>
    <div
      v-if="value"
      class="break-words"
      :class="isWhatsAppLayout ? 'text-[13px] leading-5 text-[#111b21]' : ''"
    >
      <slot>
        {{ value }}
      </slot>
    </div>
  </div>
</template>
