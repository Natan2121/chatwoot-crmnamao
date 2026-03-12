<script setup>
import { computed, defineEmits } from 'vue';
import { OnClickOutside } from '@vueuse/components';
import { useToggle } from '@vueuse/core';

import Button from 'dashboard/components-next/button/Button.vue';
import Avatar from 'next/avatar/Avatar.vue';
import MultiselectDropdownItems from 'shared/components/ui/MultiselectDropdownItems.vue';

const props = defineProps({
  options: {
    type: Array,
    default: () => [],
  },
  selectedItem: {
    type: Object,
    default: () => ({}),
  },
  hasThumbnail: {
    type: Boolean,
    default: true,
  },
  multiselectorTitle: {
    type: String,
    default: '',
  },
  multiselectorPlaceholder: {
    type: String,
    default: 'None',
  },
  noSearchResult: {
    type: String,
    default: 'No results found',
  },
  inputPlaceholder: {
    type: String,
    default: 'Search',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  isWhatsAppLayout: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['select']);
const [showSearchDropdown, toggleDropdown] = useToggle(false);

const onCloseDropdown = () => toggleDropdown(false);
const onClickSelectItem = value => {
  emit('select', value);
  onCloseDropdown();
};

const hasValue = computed(() => {
  if (props.selectedItem && props.selectedItem.id) {
    return true;
  }
  return false;
});
</script>

<template>
  <OnClickOutside @trigger="onCloseDropdown">
    <div
      class="multiselect-dropdown relative w-full mb-2"
      :class="isWhatsAppLayout ? 'multiselect-dropdown--whatsapp' : ''"
      @keyup.esc="onCloseDropdown"
    >
      <Button
        slate
        outline
        trailing-icon
        :icon="
          showSearchDropdown ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'
        "
        class="w-full !px-2"
        :class="isWhatsAppLayout ? 'multiselect-dropdown__button' : ''"
        type="button"
        :disabled="disabled"
        @click="
          () => toggleDropdown() // ensure that the event is not passed to the button
        "
      >
        <div class="flex items-center justify-between w-full min-w-0">
          <h4
            v-if="!hasValue"
            class="text-sm text-ellipsis"
            :class="isWhatsAppLayout ? 'text-[#667781]' : 'text-n-slate-12'"
          >
            {{ multiselectorPlaceholder }}
          </h4>
          <h4
            v-else
            class="items-center overflow-hidden text-sm leading-tight whitespace-nowrap text-ellipsis"
            :class="isWhatsAppLayout ? 'text-[#111b21]' : 'text-n-slate-12'"
            :title="selectedItem.name"
          >
            {{ selectedItem.name }}
          </h4>
        </div>
        <Avatar
          v-if="hasValue && hasThumbnail"
          :src="selectedItem.thumbnail"
          :status="selectedItem.availability_status"
          :name="selectedItem.name"
          :size="24"
          hide-offline-status
          rounded-full
        />
      </Button>
      <!-- NOTE: Without @click.prevent, the dropdown does not behave as expected when used inside a <label> tag. -->
      <div
        class="box-border top-[2.625rem] w-full absolute p-2 z-[9999]"
        :class="[
          {
            'block visible': showSearchDropdown,
            'hidden invisible': !showSearchDropdown,
          },
          isWhatsAppLayout
            ? 'multiselect-dropdown__menu rounded-2xl border border-[#dfe5e7] bg-white shadow-[0_12px_32px_rgba(17,27,33,0.12)]'
            : 'border rounded-lg bg-n-alpha-3 backdrop-blur-[100px] shadow-lg border-n-strong dark:border-n-strong',
        ]"
        @click.prevent
      >
        <div class="flex items-center justify-between mb-1">
          <h4
            class="m-0 overflow-hidden text-sm whitespace-nowrap text-ellipsis"
            :class="isWhatsAppLayout ? 'text-[#111b21]' : 'text-n-slate-11'"
          >
            {{ multiselectorTitle }}
          </h4>
          <Button
            ghost
            slate
            xs
            icon="i-lucide-x"
            :class="isWhatsAppLayout ? 'multiselect-dropdown__close' : ''"
            @click="onCloseDropdown"
          />
        </div>
        <MultiselectDropdownItems
          v-if="showSearchDropdown"
          :options="options"
          :selected-items="[selectedItem]"
          :has-thumbnail="hasThumbnail"
          :input-placeholder="inputPlaceholder"
          :no-search-result="noSearchResult"
          :is-whats-app-layout="isWhatsAppLayout"
          @select="onClickSelectItem"
        />
      </div>
    </div>
  </OnClickOutside>
</template>

<style scoped lang="scss">
.multiselect-dropdown--whatsapp {
  :deep(.multiselect-dropdown__button) {
    @apply rounded-2xl border border-[#dfe5e7] bg-white px-3 py-2 shadow-none;
  }

  :deep(.multiselect-dropdown__button:hover) {
    background-color: #f7f8fa;
  }

  :deep(.multiselect-dropdown__button .button__icon) {
    @apply text-[#54656f];
  }

  :deep(.multiselect-dropdown__close) {
    @apply rounded-full border-0 text-[#54656f];
    background-color: #f7f8fa;
  }

  :deep(.multiselect-dropdown__close:hover) {
    background-color: #f0f2f5;
  }
}
</style>
