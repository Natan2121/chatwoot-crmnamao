<script>
import { ref } from 'vue';
import { mapGetters } from 'vuex';
import { useAdmin } from 'dashboard/composables/useAdmin';
import { useConversationLabels } from 'dashboard/composables/useConversationLabels';
import { useKeyboardEvents } from 'dashboard/composables/useKeyboardEvents';
import Spinner from 'shared/components/Spinner.vue';
import LabelDropdown from 'shared/components/ui/label/LabelDropdown.vue';
import AddLabel from 'shared/components/ui/dropdown/AddLabel.vue';

export default {
  components: {
    Spinner,
    LabelDropdown,
    AddLabel,
  },
  props: {
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  setup() {
    const { isAdmin } = useAdmin();

    const {
      savedLabels,
      activeLabels,
      accountLabels,
      addLabelToConversation,
      removeLabelFromConversation,
    } = useConversationLabels();

    const showSearchDropdownLabel = ref(false);

    const toggleLabels = () => {
      showSearchDropdownLabel.value = !showSearchDropdownLabel.value;
    };

    const closeDropdownLabel = () => {
      showSearchDropdownLabel.value = false;
    };

    const keyboardEvents = {
      KeyL: {
        action: e => {
          e.preventDefault();
          toggleLabels();
        },
      },
      Escape: {
        action: () => {
          if (showSearchDropdownLabel.value) {
            toggleLabels();
          }
        },
        allowOnFocusedInput: true,
      },
    };
    useKeyboardEvents(keyboardEvents);
    return {
      isAdmin,
      savedLabels,
      activeLabels,
      accountLabels,
      addLabelToConversation,
      removeLabelFromConversation,
      showSearchDropdownLabel,
      closeDropdownLabel,
      toggleLabels,
    };
  },
  data() {
    return {
      selectedLabels: [],
    };
  },

  computed: {
    ...mapGetters({
      conversationUiFlags: 'conversationLabels/getUIFlags',
    }),
  },
};
</script>

<template>
  <div
    class="sidebar-labels-wrap"
    :class="isWhatsAppLayout ? 'sidebar-labels-wrap--whatsapp' : ''"
  >
    <div
      v-if="!conversationUiFlags.isFetching"
      class="contact-conversation--list"
    >
      <div
        v-on-clickaway="closeDropdownLabel"
        class="label-wrap flex flex-wrap"
        @keyup.esc="closeDropdownLabel"
      >
        <AddLabel
          class="sidebar-labels-wrap__add"
          :is-whats-app-layout="isWhatsAppLayout"
          @add="toggleLabels"
        />
        <woot-label
          v-for="label in activeLabels"
          :key="label.id"
          :title="label.title"
          :description="label.description"
          show-close
          :color="label.color"
          variant="smooth"
          class="max-w-[calc(100%-0.5rem)]"
          @remove="removeLabelFromConversation"
        />

        <div
          class="top-6 absolute w-full p-2 box-border z-[9999]"
          :class="[
            {
              'block visible': showSearchDropdownLabel,
              'hidden invisible': !showSearchDropdownLabel,
            },
            isWhatsAppLayout
              ? 'rounded-2xl border border-[#dfe5e7] bg-white shadow-[0_12px_32px_rgba(17,27,33,0.12)]'
              : 'border rounded-lg bg-n-alpha-3 backdrop-blur-[100px] shadow-lg border-n-strong dark:border-n-strong',
          ]"
        >
          <LabelDropdown
            v-if="showSearchDropdownLabel"
            :account-labels="accountLabels"
            :selected-labels="savedLabels"
            :allow-creation="isAdmin"
            :is-whats-app-layout="isWhatsAppLayout"
            @add="addLabelToConversation"
            @remove="removeLabelFromConversation"
          />
        </div>
      </div>
    </div>
    <Spinner v-else />
  </div>
</template>

<style lang="scss" scoped>
.sidebar-labels-wrap {
  margin-bottom: 0;
}
.contact-conversation--list {
  width: 100%;

  .label-wrap {
    line-height: 1.5rem;
    position: relative;
  }
}

.sidebar-labels-wrap--whatsapp {
  :deep(.sidebar-labels-wrap__add button) {
    @apply rounded-full border-0 text-[#54656f];
    background-color: #ffffff;
  }

  :deep(.sidebar-labels-wrap__add button:hover) {
    background-color: #f0f2f5;
  }

  :deep(.woot-label) {
    border-color: #dfe5e7 !important;
    background-color: #ffffff !important;
    color: #111b21 !important;
    border-radius: 9999px !important;
  }
}
</style>
