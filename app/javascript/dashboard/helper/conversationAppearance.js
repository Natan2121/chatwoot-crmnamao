import { INBOX_TYPES } from 'dashboard/helper/inbox';

export const CONVERSATION_VISUAL_MODES = Object.freeze({
  DEFAULT: 'default',
  WHATSAPP: 'whatsapp',
});

export const DEFAULT_CONVERSATION_VISUAL_MODE =
  CONVERSATION_VISUAL_MODES.WHATSAPP;

export const isWhatsAppConversationInbox = inbox => {
  if (!inbox) {
    return false;
  }

  const channelType = inbox.channelType || inbox.channel_type;
  const medium = inbox.medium || '';

  return (
    channelType === INBOX_TYPES.WHATSAPP ||
    channelType === INBOX_TYPES.API ||
    (channelType === INBOX_TYPES.TWILIO && medium === 'whatsapp')
  );
};

export const resolveConversationVisualMode = (uiSettings, inbox) => {
  const normalizedUiSettings = uiSettings || {};
  const configuredMode = normalizedUiSettings.conversation_visual_mode;

  if (configuredMode === CONVERSATION_VISUAL_MODES.DEFAULT) {
    return CONVERSATION_VISUAL_MODES.DEFAULT;
  }

  if (!isWhatsAppConversationInbox(inbox)) {
    return CONVERSATION_VISUAL_MODES.DEFAULT;
  }

  return configuredMode || DEFAULT_CONVERSATION_VISUAL_MODE;
};

export const shouldUseWhatsAppConversationLayout = (uiSettings, inbox) => {
  return (
    resolveConversationVisualMode(uiSettings, inbox) ===
    CONVERSATION_VISUAL_MODES.WHATSAPP
  );
};

export const isConversationWorkspaceRoute = route => {
  if (!route) {
    return false;
  }

  const routeName = String(route.name || '');
  const path = route.path || '';

  return (
    routeName === 'home' ||
    routeName.includes('conversation') ||
    path.includes('/conversations') ||
    path.includes('/inboxes/')
  );
};

export const shouldUseWhatsAppWorkspaceLayout = (uiSettings, inbox, route) => {
  return (
    shouldUseWhatsAppConversationLayout(uiSettings, inbox) &&
    isConversationWorkspaceRoute(route)
  );
};
