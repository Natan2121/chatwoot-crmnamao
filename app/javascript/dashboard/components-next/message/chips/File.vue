<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { getFileInfo } from '@chatwoot/utils';

import FileIcon from 'next/icon/FileIcon.vue';
import Icon from 'next/icon/Icon.vue';
import { useMessageContext } from '../provider.js';

const { attachment } = defineProps({
  attachment: {
    type: Object,
    required: true,
  },
});

const { t } = useI18n();
const { isWhatsAppLayout } = useMessageContext();

const fileDetails = computed(() => {
  return getFileInfo(attachment?.dataUrl || '');
});

const formatFileSize = size => {
  if (!size || Number.isNaN(Number(size))) return '';

  const units = ['B', 'KB', 'MB', 'GB'];
  let value = Number(size);
  let unitIndex = 0;

  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }

  const roundedValue =
    value >= 10 || unitIndex === 0 ? Math.round(value) : value.toFixed(1);
  return `${roundedValue} ${units[unitIndex]}`;
};

const displayFileName = computed(() => {
  const { base, type } = fileDetails.value;
  const truncatedName = (str, maxLength, hasExt) =>
    str.length > maxLength
      ? `${str.substring(0, maxLength).trimEnd()}${hasExt ? '..' : '...'}`
      : str;

  return type
    ? `${truncatedName(base, 12, true)}.${type}`
    : truncatedName(base, 14, false);
});

const textColorClass = computed(() => {
  const colorMap = {
    '7z': 'dark:text-[#EDEEF0] text-[#2F265F]',
    csv: 'text-n-amber-12',
    doc: 'dark:text-[#D6E1FF] text-[#1F2D5C]', // indigo-12
    docx: 'dark:text-[#D6E1FF] text-[#1F2D5C]', // indigo-12
    json: 'text-n-slate-12',
    odt: 'dark:text-[#D6E1FF] text-[#1F2D5C]', // indigo-12
    pdf: 'text-n-slate-12',
    ppt: 'dark:text-[#FFE0C2] text-[#582D1D]',
    pptx: 'dark:text-[#FFE0C2] text-[#582D1D]',
    rar: 'dark:text-[#EDEEF0] text-[#2F265F]',
    rtf: 'dark:text-[#D6E1FF] text-[#1F2D5C]', // indigo-12
    tar: 'dark:text-[#EDEEF0] text-[#2F265F]',
    txt: 'text-n-slate-12',
    xls: 'text-n-teal-12',
    xlsx: 'text-n-teal-12',
    zip: 'dark:text-[#EDEEF0] text-[#2F265F]',
  };

  return colorMap[fileDetails.value.type] || 'text-n-slate-12';
});

const iconPanelClass = computed(() => {
  const colorMap = {
    pdf: 'bg-[#fce8e6] text-[#b42318]',
    doc: 'bg-[#dbeafe] text-[#1d4ed8]',
    docx: 'bg-[#dbeafe] text-[#1d4ed8]',
    xls: 'bg-[#dcfce7] text-[#15803d]',
    xlsx: 'bg-[#dcfce7] text-[#15803d]',
    csv: 'bg-[#fef3c7] text-[#b45309]',
    ppt: 'bg-[#ffedd5] text-[#c2410c]',
    pptx: 'bg-[#ffedd5] text-[#c2410c]',
    zip: 'bg-[#ede9fe] text-[#6d28d9]',
    rar: 'bg-[#ede9fe] text-[#6d28d9]',
  };

  return colorMap[fileDetails.value.type] || 'bg-[#e9edef] text-[#54656f]';
});

const fileExtensionLabel = computed(() => {
  return (fileDetails.value.type || 'file').toUpperCase();
});

const fileSizeLabel = computed(() => formatFileSize(attachment?.fileSize));
</script>

<template>
  <div
    class="overflow-hidden border"
    :class="
      isWhatsAppLayout
        ? 'flex w-full max-w-[19rem] items-center gap-3 rounded-[18px] border-white/60 bg-white/85 p-3 shadow-[0_1px_2px_rgba(11,20,26,0.1)]'
        : 'flex h-9 items-center gap-2 rounded-lg bg-n-alpha-white border-n-container px-2'
    "
  >
    <div
      v-if="isWhatsAppLayout"
      class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-2xl"
      :class="iconPanelClass"
    >
      <div class="flex flex-col items-center leading-none">
        <FileIcon class="flex-shrink-0" :file-type="fileDetails.type" />
        <span class="mt-1 text-[10px] font-semibold tracking-[0.08em]">
          {{ fileExtensionLabel }}
        </span>
      </div>
    </div>
    <FileIcon v-else class="flex-shrink-0" :file-type="fileDetails.type" />
    <div class="min-w-0 flex-1">
      <span
        class="block min-w-0 text-sm"
        :title="fileDetails.name"
        :class="[
          textColorClass,
          isWhatsAppLayout
            ? 'max-w-full font-medium text-[#111b21]'
            : 'max-w-36',
        ]"
      >
        {{ displayFileName }}
      </span>
      <span
        v-if="isWhatsAppLayout && fileSizeLabel"
        class="mt-1 block text-xs text-[#667781]"
      >
        {{ fileSizeLabel }}
      </span>
    </div>
    <a
      v-tooltip="t('CONVERSATION.DOWNLOAD')"
      class="grid flex-shrink-0 cursor-pointer place-content-center transition-colors"
      :class="
        isWhatsAppLayout
          ? 'h-10 w-10 rounded-full bg-[#f0f2f5] text-[#54656f] hover:bg-[#e9edef] hover:text-[#111b21]'
          : 'size-9 text-n-slate-11 hover:text-n-slate-12'
      "
      :href="attachment.dataUrl"
      rel="noreferrer noopener nofollow"
      target="_blank"
    >
      <Icon icon="i-lucide-download" />
    </a>
  </div>
</template>
