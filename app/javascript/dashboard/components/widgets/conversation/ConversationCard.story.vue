<script setup>
import ConversationCard from './ConversationCard.vue';
import { useWhatsAppConversationStoryState } from 'dashboard/helper/story/whatsAppConversationStoryState';

const whatsappInbox = {
  id: 42,
  name: 'Licencas no Mao',
  channel_type: 'Channel::Api',
  medium: 'whatsapp',
  phone_number: '+5511983553712',
};

const labels = [
  {
    id: 1,
    title: 'vip',
    description: 'Clientes quentes com prioridade alta',
    color: '#25D366',
    show_on_sidebar: true,
  },
  {
    id: 2,
    title: 'documentos',
    description: 'Precisa de envio de arquivos',
    color: '#53BDEB',
    show_on_sidebar: true,
  },
  {
    id: 3,
    title: 'fup',
    description: 'Follow-up manual ou comercial',
    color: '#FF9F0A',
    show_on_sidebar: true,
  },
];

const contacts = {
  101: {
    id: 101,
    name: 'Bruna Leal',
    availability_status: 'online',
    thumbnail: 'https://api.dicebear.com/9.x/lorelei/svg?seed=Bruna',
    phone_number: '+5511999990001',
  },
  102: {
    id: 102,
    name: 'Carlos Henrique',
    availability_status: 'offline',
    thumbnail: 'https://api.dicebear.com/9.x/lorelei/svg?seed=Carlos',
    phone_number: '+5511999990002',
  },
  103: {
    id: 103,
    name: 'Financeiro Norte',
    availability_status: 'offline',
    thumbnail: 'https://api.dicebear.com/9.x/shapes/svg?seed=Financeiro',
    phone_number: '+5511999990003',
  },
};

const makeMessage = ({
  id,
  content,
  createdAt,
  messageType = 0,
  attachments = [],
  privateMessage = false,
}) => ({
  id,
  content,
  created_at: createdAt,
  message_type: messageType,
  content_type: 'text',
  private: privateMessage,
  attachments,
});

const conversations = [
  {
    id: 9001,
    inbox_id: 42,
    status: 'open',
    created_at: 1741740780,
    timestamp: 1741742460,
    unread_count: 4,
    priority: 'urgent',
    labels: ['vip', 'fup'],
    sla_policy_id: 9,
    additional_attributes: {},
    meta: {
      sender: { id: 101 },
      assignee: { id: 1, name: 'Natan' },
    },
    messages: [
      makeMessage({
        id: 1,
        content: 'Consegue me mandar a proposta final ainda hoje?',
        createdAt: 1741742460,
      }),
    ],
    last_non_activity_message: makeMessage({
      id: 1,
      content: 'Consegue me mandar a proposta final ainda hoje?',
      createdAt: 1741742460,
    }),
  },
  {
    id: 9002,
    inbox_id: 42,
    status: 'open',
    created_at: 1741738200,
    timestamp: 1741742520,
    unread_count: 0,
    priority: 'high',
    labels: ['documentos'],
    additional_attributes: {},
    meta: {
      sender: { id: 102 },
      assignee: { id: 7, name: 'Operacao' },
    },
    messages: [
      makeMessage({
        id: 2,
        content: 'Perfeito. Audio recebido e contrato separado em PDF.',
        createdAt: 1741742520,
        messageType: 1,
      }),
    ],
    last_non_activity_message: makeMessage({
      id: 2,
      content: 'Perfeito. Audio recebido e contrato separado em PDF.',
      createdAt: 1741742520,
      messageType: 1,
    }),
  },
  {
    id: 9003,
    inbox_id: 42,
    status: 'open',
    created_at: 1741734000,
    timestamp: 1741741200,
    unread_count: 1,
    priority: null,
    labels: [],
    additional_attributes: {
      call_status: 'completed',
      call_direction: 'outbound',
    },
    meta: {
      sender: { id: 103 },
      assignee: { id: 4, name: 'Financeiro' },
    },
    messages: [
      makeMessage({
        id: 3,
        content: 'Ligacao finalizada',
        createdAt: 1741741200,
        messageType: 2,
      }),
    ],
  },
];

const shellInitials = 'LN';
const shellTitle = 'Conversas';
const shellSubtitle = 'Modo WhatsApp';
const shellCountLabel = '3 ativas';

useWhatsAppConversationStoryState({
  inboxes: [whatsappInbox],
  contacts,
  conversations,
  labels,
  selectedChatId: 9002,
});
</script>

<template>
  <Story
    title="Components/Conversation/WhatsApp Card"
    :layout="{ type: 'single' }"
  >
    <Variant title="Sidebar list">
      <div
        class="w-[420px] overflow-hidden rounded-[24px] border border-[#d1d7db] shadow-[0_18px_50px_rgba(17,27,33,0.12)]"
      >
        <div class="flex items-center justify-between bg-[#202c33] px-4 py-3">
          <div class="flex items-center gap-3">
            <span
              class="flex size-10 items-center justify-center rounded-full bg-[#111b21] text-sm font-semibold text-[#e9edef]"
            >
              {{ shellInitials }}
            </span>
            <div>
              <p class="m-0 text-sm font-semibold text-[#e9edef]">
                {{ shellTitle }}
              </p>
              <p class="m-0 text-xs text-[#8696a0]">{{ shellSubtitle }}</p>
            </div>
          </div>
          <div class="flex items-center gap-2 text-[#aebac1]">
            <span class="rounded-full bg-[#111b21] px-2.5 py-1 text-xs">
              {{ shellCountLabel }}
            </span>
          </div>
        </div>
        <div class="bg-[#f0f2f5]">
          <ConversationCard
            v-for="chat in conversations"
            :key="chat.id"
            :chat="chat"
            show-assignee
          />
        </div>
      </div>
    </Variant>
    <Variant title="Selection state">
      <div
        class="w-[360px] overflow-hidden rounded-[24px] border border-[#d1d7db] shadow-[0_18px_50px_rgba(17,27,33,0.12)]"
      >
        <div class="bg-[#f0f2f5]">
          <ConversationCard :chat="conversations[0]" show-assignee selected />
          <ConversationCard :chat="conversations[1]" show-assignee compact />
        </div>
      </div>
    </Variant>
  </Story>
</template>
