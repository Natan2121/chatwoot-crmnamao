<script>
import ConversationCard from 'dashboard/components/widgets/conversation/ConversationCard.vue';
import { mapGetters } from 'vuex';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

export default {
  components: {
    ConversationCard,
    Spinner,
  },
  props: {
    contactId: {
      type: [String, Number],
      required: true,
    },
    conversationId: {
      type: [String, Number],
      required: true,
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  computed: {
    conversations() {
      return this.$store.getters['contactConversations/getContactConversation'](
        this.contactId
      );
    },
    previousConversations() {
      return this.conversations.filter(
        conversation => conversation.id !== Number(this.conversationId)
      );
    },
    ...mapGetters({
      uiFlags: 'contactConversations/getUIFlags',
    }),
  },
  watch: {
    contactId(newContactId, prevContactId) {
      if (newContactId && newContactId !== prevContactId) {
        this.$store.dispatch('contactConversations/get', newContactId);
      }
    },
  },
  mounted() {
    this.$store.dispatch('contactConversations/get', this.contactId);
  },
};
</script>

<template>
  <div v-if="!uiFlags.isFetching" class="">
    <div
      v-if="!previousConversations.length"
      class="no-label-message px-4 p-3"
      :class="isWhatsAppLayout ? 'no-label-message--whatsapp' : ''"
    >
      <span>
        {{ $t('CONTACT_PANEL.CONVERSATIONS.NO_RECORDS_FOUND') }}
      </span>
    </div>
    <div
      v-else
      class="contact-conversation--list"
      :class="isWhatsAppLayout ? 'contact-conversation--list-whatsapp' : ''"
    >
      <ConversationCard
        v-for="conversation in previousConversations"
        :key="conversation.id"
        :chat="conversation"
        :hide-inbox-name="false"
        hide-thumbnail
        enable-context-menu
        compact
        :allowed-context-menu-options="['open-new-tab', 'copy-link']"
      />
    </div>
  </div>
  <div v-else class="flex items-center justify-center py-5">
    <Spinner />
  </div>
</template>

<style lang="scss" scoped>
.no-label-message {
  @apply text-n-slate-11 mb-4;
}

.no-label-message--whatsapp {
  @apply rounded-2xl border border-[#e3e6e8] bg-[#f7f8fa] mb-0 text-[#667781];
}

.contact-conversation--list-whatsapp {
  @apply flex flex-col gap-2;
}
</style>
