<script>
import LabelDropdownItem from './LabelDropdownItem.vue';
import Hotkey from 'dashboard/components/base/Hotkey.vue';
import AddLabelModal from 'dashboard/routes/dashboard/settings/labels/AddLabel.vue';
import { picoSearch } from '@scmmishra/pico-search';
import { sanitizeLabel } from 'shared/helpers/sanitizeData';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    LabelDropdownItem,
    AddLabelModal,
    Hotkey,
    NextButton,
  },

  props: {
    accountLabels: {
      type: Array,
      default: () => [],
    },
    selectedLabels: {
      type: Array,
      default: () => [],
    },
    allowCreation: {
      type: Boolean,
      default: false,
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['update', 'add', 'remove'],

  data() {
    return {
      search: '',
      createModalVisible: false,
      hotkeyLabel: 'L',
    };
  },

  computed: {
    createLabelPlaceholder() {
      const label = this.$t('CONTACT_PANEL.LABELS.LABEL_SELECT.CREATE_LABEL');
      return this.search ? `${label}:` : label;
    },

    filteredActiveLabels() {
      if (!this.search) return this.accountLabels;

      return picoSearch(this.accountLabels, this.search, ['title'], {
        threshold: 0.9,
      });
    },

    noResult() {
      return this.filteredActiveLabels.length === 0;
    },

    hasExactMatchInResults() {
      return this.filteredActiveLabels.some(
        label => label.title === this.search
      );
    },

    shouldShowCreate() {
      return this.allowCreation && this.filteredActiveLabels.length < 3;
    },

    parsedSearch() {
      return sanitizeLabel(this.search);
    },
  },

  mounted() {
    this.focusInput();
  },

  methods: {
    focusInput() {
      this.$refs.searchbar.focus();
    },

    updateLabels(label) {
      this.$emit('update', label);
    },

    onAdd(label) {
      this.$emit('add', label);
    },

    onRemove(label) {
      this.$emit('remove', label);
    },

    onAddRemove(label) {
      if (this.selectedLabels.includes(label.title)) {
        this.onRemove(label.title);
      } else {
        this.onAdd(label);
      }
    },

    showCreateModal() {
      this.createModalVisible = true;
    },

    hideCreateModal() {
      this.createModalVisible = false;
    },
  },
};
</script>

<template>
  <div
    class="flex flex-col w-full max-h-[12.5rem]"
    :class="isWhatsAppLayout ? 'label-dropdown--whatsapp' : ''"
  >
    <div class="flex items-center justify-center mb-1">
      <h4
        class="flex-grow m-0 overflow-hidden text-sm whitespace-nowrap text-ellipsis"
        :class="isWhatsAppLayout ? 'text-[#111b21]' : 'text-n-slate-12'"
      >
        {{ $t('CONTACT_PANEL.LABELS.LABEL_SELECT.TITLE') }}
      </h4>
      <Hotkey
        :custom-class="
          isWhatsAppLayout
            ? 'border border-solid border-[#dfe5e7] bg-[#f7f8fa] text-[#54656f] text-xxs flex-shrink-0'
            : 'border border-solid text-n-slate-12 bg-n-slate-2 text-xxs border-n-strong flex-shrink-0'
        "
      >
        {{ hotkeyLabel }}
      </Hotkey>
    </div>
    <div class="flex-auto flex-grow-0 flex-shrink-0 mb-2 max-h-8">
      <input
        ref="searchbar"
        v-model="search"
        type="text"
        class="search-input"
        :class="isWhatsAppLayout ? 'search-input--whatsapp' : ''"
        autofocus="true"
        :placeholder="$t('CONTACT_PANEL.LABELS.LABEL_SELECT.PLACEHOLDER')"
      />
    </div>
    <div
      class="flex items-start justify-start flex-auto flex-grow flex-shrink overflow-auto"
    >
      <div class="w-full my-1">
        <woot-dropdown-menu>
          <LabelDropdownItem
            v-for="label in filteredActiveLabels"
            :key="label.title"
            :title="label.title"
            :color="label.color"
            :selected="selectedLabels.includes(label.title)"
            :is-whats-app-layout="isWhatsAppLayout"
            @select-label="onAddRemove(label)"
          />
        </woot-dropdown-menu>
        <div
          v-if="noResult"
          class="flex justify-center py-4 px-2.5 font-medium text-xs text-n-slate-11"
        >
          {{ $t('CONTACT_PANEL.LABELS.LABEL_SELECT.NO_RESULT') }}
        </div>
        <div
          v-if="allowCreation && shouldShowCreate"
          class="flex pt-1 border-t border-solid border-n-weak"
        >
          <NextButton
            icon="i-lucide-plus"
            slate
            sm
            ghost
            :class="isWhatsAppLayout ? 'label-dropdown__create' : ''"
            :label="`${createLabelPlaceholder} ${parsedSearch}`"
            :disabled="hasExactMatchInResults"
            @click="showCreateModal"
          />

          <woot-modal
            v-model:show="createModalVisible"
            :on-close="hideCreateModal"
          >
            <AddLabelModal
              :prefill-title="parsedSearch"
              @close="hideCreateModal"
            />
          </woot-modal>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.label-dropdown--whatsapp {
  .search-input--whatsapp {
    @apply rounded-2xl border border-[#dfe5e7] bg-[#f7f8fa] px-3 text-[#111b21];
  }

  :deep(.label-dropdown__create button) {
    @apply rounded-2xl border border-transparent text-[#008069];
  }

  :deep(.label-dropdown__create button:hover) {
    background-color: #f7f8fa;
  }
}
</style>
