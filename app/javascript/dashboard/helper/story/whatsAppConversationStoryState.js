import { onBeforeUnmount } from 'vue';
import store from 'dashboard/store';
import { CONVERSATION_VISUAL_MODES } from 'dashboard/helper/conversationAppearance';

const cloneState = value => {
  if (value === undefined) {
    return undefined;
  }

  return JSON.parse(JSON.stringify(value));
};

const defaultAccount = accountId => ({
  id: accountId,
  name: 'Story Account',
  role: 'administrator',
  availability: 'online',
  auto_offline: false,
});

export const useWhatsAppConversationStoryState = ({
  routeAccountId = 1,
  inboxes = [],
  contacts = {},
  conversations = [],
  selectedChatId = null,
  currentInbox,
  attachments = {},
  labels = [],
  uiSettings = {},
} = {}) => {
  const snapshot = {
    route: cloneState(store.state.route),
    currentUser: cloneState(store.state.auth.currentUser),
    inboxes: cloneState(store.state.inboxes.records),
    contacts: cloneState(store.state.contacts.records),
    contactOrder: cloneState(store.state.contacts.sortOrder),
    labels: cloneState(store.state.labels.records),
    conversations: cloneState(store.state.conversations.allConversations),
    selectedChatId: store.state.conversations.selectedChatId,
    currentInbox: cloneState(store.state.conversations.currentInbox),
    attachments: cloneState(store.state.conversations.attachments),
  };

  const previousUser = snapshot.currentUser || {};
  const previousSettings = previousUser.ui_settings || {};
  const resolvedCurrentInbox =
    currentInbox === undefined ? inboxes[0] || null : currentInbox;

  store.state.route = {
    ...(snapshot.route || {}),
    params: {
      ...(snapshot.route?.params || {}),
      accountId: String(routeAccountId),
    },
  };

  store.state.auth.currentUser = {
    ...previousUser,
    id: previousUser.id || 1,
    account_id: routeAccountId,
    name: previousUser.name || 'Story Agent',
    email: previousUser.email || 'story-agent@chatwoot.dev',
    accounts:
      previousUser.accounts && previousUser.accounts.length
        ? previousUser.accounts
        : [defaultAccount(routeAccountId)],
    ui_settings: {
      ...previousSettings,
      conversation_visual_mode: CONVERSATION_VISUAL_MODES.WHATSAPP,
      ...uiSettings,
    },
  };

  store.state.inboxes.records = cloneState(inboxes);
  store.state.contacts.records = cloneState(contacts);
  store.state.contacts.sortOrder = Object.keys(contacts).map(id => Number(id));
  store.state.labels.records = cloneState(labels);
  store.state.conversations.allConversations = cloneState(conversations);
  store.state.conversations.selectedChatId = selectedChatId;
  store.state.conversations.currentInbox = cloneState(resolvedCurrentInbox);
  store.state.conversations.attachments = cloneState(attachments);
  store.state.conversations.listLoadingStatus = false;

  onBeforeUnmount(() => {
    if (snapshot.route === undefined) {
      delete store.state.route;
    } else {
      store.state.route = snapshot.route;
    }

    store.state.auth.currentUser = snapshot.currentUser;
    store.state.inboxes.records = snapshot.inboxes;
    store.state.contacts.records = snapshot.contacts;
    store.state.contacts.sortOrder = snapshot.contactOrder;
    store.state.labels.records = snapshot.labels;
    store.state.conversations.allConversations = snapshot.conversations;
    store.state.conversations.selectedChatId = snapshot.selectedChatId;
    store.state.conversations.currentInbox = snapshot.currentInbox;
    store.state.conversations.attachments = snapshot.attachments;
  });
};
