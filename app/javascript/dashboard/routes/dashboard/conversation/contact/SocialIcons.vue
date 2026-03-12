<script>
export default {
  props: {
    socialProfiles: {
      type: Object,
      default: () => ({}),
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      socialMediaLinks: [
        { key: 'facebook', icon: 'facebook', link: 'https://facebook.com/' },
        { key: 'twitter', icon: 'twitter', link: 'https://twitter.com/' },
        { key: 'linkedin', icon: 'linkedin', link: 'https://linkedin.com/' },
        { key: 'github', icon: 'github', link: 'https://github.com/' },
        { key: 'instagram', icon: 'instagram', link: 'https://instagram.com/' },
        { key: 'telegram', icon: 'telegram', link: 'https://t.me/' },
        { key: 'tiktok', icon: 'tiktok', link: 'https://tiktok.com/@' },
      ],
    };
  },
  computed: {
    availableProfiles() {
      return this.socialMediaLinks.filter(
        mediaLink => !!this.socialProfiles[mediaLink.key]
      );
    },
  },
};
</script>

<!-- eslint-disable-next-line vue/no-root-v-if -->
<template>
  <div
    v-if="availableProfiles.length"
    class="flex items-end mx-0 my-2"
    :class="isWhatsAppLayout ? 'gap-2 pt-1' : 'gap-3'"
  >
    <a
      v-for="profile in availableProfiles"
      :key="profile.key"
      :href="`${profile.link}${socialProfiles[profile.key]}`"
      target="_blank"
      rel="noopener noreferrer nofollow"
      class="social-icons__link"
      :class="isWhatsAppLayout ? 'social-icons__link--whatsapp' : ''"
    >
      <fluent-icon
        :icon="`brand-${profile.key}`"
        size="16"
        class="text-n-slate-11 hover:text-n-slate-10"
        :class="isWhatsAppLayout ? '!text-[#54656f]' : ''"
      />
    </a>
  </div>
</template>

<style scoped lang="scss">
.social-icons__link--whatsapp {
  @apply inline-flex size-9 items-center justify-center rounded-full border border-[#dfe5e7] bg-white;
  box-shadow: 0 1px 2px rgba(17, 27, 33, 0.05);

  &:hover {
    background-color: #f0f2f5;
  }
}
</style>
