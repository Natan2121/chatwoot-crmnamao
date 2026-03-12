<script>
import FeaturePlaceholder from './FeaturePlaceholder.vue';
export default {
  components: { FeaturePlaceholder },
  props: {
    message: {
      type: String,
      required: true,
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
};
</script>

<template>
  <div
    class="flex flex-col items-center justify-center h-full"
    :class="
      isWhatsAppLayout
        ? 'rounded-[2rem] border border-white/60 bg-white/75 px-10 py-12 shadow-[0_8px_28px_rgba(17,27,33,0.08)] backdrop-blur-sm'
        : ''
    "
  >
    <img
      class="m-4 w-32 hidden dark:block"
      src="dashboard/assets/images/no-chat-dark.svg"
      alt="No Chat dark"
    />
    <img
      class="m-4 block dark:hidden"
      :class="isWhatsAppLayout ? 'w-40 opacity-90' : 'w-32'"
      src="dashboard/assets/images/no-chat.svg"
      alt="No Chat"
    />
    <span
      class="text-center"
      :class="
        isWhatsAppLayout
          ? 'text-[15px] font-medium leading-6 text-[#111b21]'
          : 'text-sm text-n-slate-12 font-medium'
      "
    >
      {{ message }}
      <br />
    </span>
    <!-- Cmd bar, keyboard shortcuts placeholder -->
    <FeaturePlaceholder />
  </div>
</template>
