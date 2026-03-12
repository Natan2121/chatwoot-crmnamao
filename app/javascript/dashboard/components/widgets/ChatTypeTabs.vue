<script setup>
import { computed } from 'vue';
import { useKeyboardEvents } from 'dashboard/composables/useKeyboardEvents';
import wootConstants from 'dashboard/constants/globals';

const props = defineProps({
  items: {
    type: Array,
    default: () => [],
  },
  activeTab: {
    type: String,
    default: wootConstants.ASSIGNEE_TYPE.ME,
  },
  isWhatsAppLayout: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['chatTabChange']);

const activeTabIndex = computed(() => {
  return props.items.findIndex(item => item.key === props.activeTab);
});

const onTabChange = selectedTabIndex => {
  if (selectedTabIndex >= 0 && selectedTabIndex < props.items.length) {
    const selectedItem = props.items[selectedTabIndex];
    if (selectedItem.key !== props.activeTab) {
      emit('chatTabChange', selectedItem.key);
    }
  }
};

const keyboardEvents = {
  'Alt+KeyN': {
    action: () => {
      if (props.activeTab === wootConstants.ASSIGNEE_TYPE.ALL) {
        onTabChange(0);
      } else {
        const nextIndex = (activeTabIndex.value + 1) % props.items.length;
        onTabChange(nextIndex);
      }
    },
  },
};

useKeyboardEvents(keyboardEvents);
</script>

<template>
  <woot-tabs
    :index="activeTabIndex"
    class="chat-type-tabs w-full py-0"
    :class="
      props.isWhatsAppLayout
        ? 'chat-type-tabs--whatsapp h-auto bg-[#f0f2f5] px-4 pb-3 pt-2'
        : 'h-10 px-3 -mt-1 [&_ul]:p-0'
    "
    @change="onTabChange"
  >
    <woot-tabs-item
      v-for="(item, index) in items"
      :key="item.key"
      class="chat-type-tabs__item text-sm"
      :index="index"
      :name="item.name"
      :count="item.count"
      is-compact
    />
  </woot-tabs>
</template>

<style scoped lang="scss">
.chat-type-tabs--whatsapp {
  :deep(ul) {
    @apply gap-2 overflow-x-auto pb-1;
  }

  :deep(li) {
    @apply shrink-0;
  }

  :deep(li a) {
    @apply rounded-full border-0 px-3 py-2 text-[13px] font-medium text-[#54656f];
    background-color: rgba(255, 255, 255, 0.92);
  }

  :deep(li a:hover) {
    background-color: #ffffff;
  }

  :deep(li[aria-selected='true'] a),
  :deep(li[aria-current='true'] a),
  :deep(li.active a) {
    @apply text-[#111b21];
    background-color: #d9fdd3;
  }
}
</style>
