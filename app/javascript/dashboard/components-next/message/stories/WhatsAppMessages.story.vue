<script setup>
import MessageList from '../MessageList.vue';
import Message from '../Message.vue';
import textWithMedia from '../fixtures/textWithMedia.js';
import { MESSAGE_STATUS, MESSAGE_TYPES, CONTENT_TYPES } from '../constants.js';
import { useWhatsAppConversationStoryState } from 'dashboard/helper/story/whatsAppConversationStoryState';

const whatsappInbox = {
  id: 486,
  name: 'WhatsApp CRM',
  channel_type: 'Channel::Api',
  medium: 'whatsapp',
  phone_number: '+5511983553712',
};

const threadTimeline = [
  1741669200, 1741669260, 1741669320, 1741669440, 1741756080, 1741756140,
];

const whatsappMessages = textWithMedia
  .filter(message => message.messageType !== MESSAGE_TYPES.TEMPLATE)
  .slice(0, 6)
  .map((message, index) => ({
    ...message,
    inboxId: 486,
    conversationId: 1016,
    createdAt: threadTimeline[index],
  }));

const deliveryStateMessages = [
  {
    id: 8101,
    content: 'Mensagem enviada agora',
    inboxId: 486,
    conversationId: 1016,
    messageType: MESSAGE_TYPES.OUTGOING,
    contentType: CONTENT_TYPES.TEXT,
    status: MESSAGE_STATUS.SENT,
    createdAt: 1741742100,
    private: false,
    sourceId: 'wamid.sent',
    senderId: 1,
    sender: { id: 1, type: 'User', name: 'Natan' },
    contentAttributes: {},
  },
  {
    id: 8102,
    content: 'Mensagem entregue ao aparelho',
    inboxId: 486,
    conversationId: 1016,
    messageType: MESSAGE_TYPES.OUTGOING,
    contentType: CONTENT_TYPES.TEXT,
    status: MESSAGE_STATUS.DELIVERED,
    createdAt: 1741742160,
    private: false,
    sourceId: 'wamid.delivered',
    senderId: 1,
    sender: { id: 1, type: 'User', name: 'Natan' },
    contentAttributes: {},
  },
  {
    id: 8103,
    content: 'Mensagem lida pelo contato',
    inboxId: 486,
    conversationId: 1016,
    messageType: MESSAGE_TYPES.OUTGOING,
    contentType: CONTENT_TYPES.TEXT,
    status: MESSAGE_STATUS.READ,
    createdAt: 1741742220,
    private: false,
    sourceId: 'wamid.read',
    senderId: 1,
    sender: { id: 1, type: 'User', name: 'Natan' },
    contentAttributes: {},
  },
];

const storyAttachments = {
  1016: whatsappMessages.flatMap(message => message.attachments || []),
};

const storyHeaderInitials = 'BL';
const storyHeaderName = 'Bruna Leal';
const storyHeaderStatus = 'online agora';
const composerPlaceholder = 'Digite uma mensagem';
const unreadDividerLabel = '2 unread messages';

const wallpaperStyle = {
  backgroundImage:
    'radial-gradient(circle at 1px 1px, rgba(17, 27, 33, 0.045) 1px, transparent 0)',
  backgroundSize: '22px 22px',
};

useWhatsAppConversationStoryState({
  inboxes: [whatsappInbox],
  conversations: [
    {
      id: 1016,
      inbox_id: 486,
      messages: whatsappMessages,
    },
  ],
  selectedChatId: 1016,
  currentInbox: whatsappInbox,
  attachments: storyAttachments,
});
</script>

<template>
  <Story
    title="Components/Messages/WhatsApp"
    :layout="{ type: 'grid', width: '920px' }"
  >
    <Variant title="Thread">
      <div
        class="w-[460px] overflow-hidden rounded-[26px] border border-[#d1d7db] shadow-[0_20px_60px_rgba(17,27,33,0.14)]"
      >
        <div class="flex items-center gap-3 bg-[#f0f2f5] px-4 py-3">
          <span
            class="flex size-10 items-center justify-center rounded-full bg-[#dfe5e7] text-sm font-semibold text-[#111b21]"
          >
            {{ storyHeaderInitials }}
          </span>
          <div>
            <p class="m-0 text-sm font-semibold text-[#111b21]">
              {{ storyHeaderName }}
            </p>
            <p class="m-0 text-xs text-[#667781]">{{ storyHeaderStatus }}</p>
          </div>
        </div>
        <div class="bg-[#efeae2]" :style="wallpaperStyle">
          <MessageList
            :current-user-id="1"
            :messages="whatsappMessages"
            :first-unread-id="whatsappMessages[4].id"
            is-whats-app-layout
          >
            <template #unreadBadge>
              <li class="list-none flex items-center gap-3 px-2 py-3">
                <span class="h-px flex-1 bg-[#d1d7db]" />
                <span
                  class="rounded-full bg-white/95 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.08em] text-[#54656f] shadow-[0_1px_2px_rgba(11,20,26,0.12)]"
                >
                  {{ unreadDividerLabel }}
                </span>
                <span class="h-px flex-1 bg-[#d1d7db]" />
              </li>
            </template>
          </MessageList>
        </div>
        <div class="bg-[#f0f2f5] px-4 py-3">
          <div
            class="rounded-full bg-white px-4 py-3 text-sm text-[#667781] shadow-[0_1px_2px_rgba(11,20,26,0.08)]"
          >
            {{ composerPlaceholder }}
          </div>
        </div>
      </div>
    </Variant>
    <Variant title="Delivery states">
      <div
        class="w-[420px] space-y-2 rounded-[26px] border border-[#d1d7db] bg-[#efeae2] p-4 shadow-[0_20px_60px_rgba(17,27,33,0.14)]"
        :style="wallpaperStyle"
      >
        <Message
          v-for="message in deliveryStateMessages"
          :key="message.id"
          :current-user-id="1"
          v-bind="message"
        />
      </div>
    </Variant>
  </Story>
</template>
