import {
  CONVERSATION_VISUAL_MODES,
  isConversationWorkspaceRoute,
  isWhatsAppConversationInbox,
  resolveConversationVisualMode,
  shouldUseWhatsAppConversationLayout,
  shouldUseWhatsAppWorkspaceLayout,
} from '../conversationAppearance';
import { INBOX_TYPES } from '../inbox';

describe('conversationAppearance', () => {
  it('treats WhatsApp-like inboxes as eligible for the WhatsApp layout', () => {
    expect(
      isWhatsAppConversationInbox({ channel_type: INBOX_TYPES.WHATSAPP })
    ).toBe(true);
    expect(
      isWhatsAppConversationInbox({
        channel_type: INBOX_TYPES.TWILIO,
        medium: 'whatsapp',
      })
    ).toBe(true);
    expect(isWhatsAppConversationInbox({ channel_type: INBOX_TYPES.API })).toBe(
      true
    );
  });

  it('keeps non-WhatsApp inboxes on the default layout', () => {
    expect(
      isWhatsAppConversationInbox({ channel_type: INBOX_TYPES.EMAIL })
    ).toBe(false);
    expect(
      isWhatsAppConversationInbox({
        channel_type: INBOX_TYPES.TWILIO,
        medium: 'sms',
      })
    ).toBe(false);
  });

  it('defaults eligible inboxes to the WhatsApp visual mode', () => {
    expect(
      resolveConversationVisualMode({}, { channel_type: INBOX_TYPES.WHATSAPP })
    ).toBe(CONVERSATION_VISUAL_MODES.WHATSAPP);
  });

  it('allows forcing the default visual mode through ui settings', () => {
    expect(
      resolveConversationVisualMode(
        { conversation_visual_mode: CONVERSATION_VISUAL_MODES.DEFAULT },
        { channel_type: INBOX_TYPES.WHATSAPP }
      )
    ).toBe(CONVERSATION_VISUAL_MODES.DEFAULT);
  });

  it('reports whether the WhatsApp layout should be active', () => {
    expect(
      shouldUseWhatsAppConversationLayout({}, { channel_type: INBOX_TYPES.API })
    ).toBe(true);
    expect(
      shouldUseWhatsAppConversationLayout(
        {},
        { channel_type: INBOX_TYPES.EMAIL }
      )
    ).toBe(false);
  });

  it('detects conversation workspace routes', () => {
    expect(
      isConversationWorkspaceRoute({
        name: 'home',
        path: '/app/accounts/1/conversations',
      })
    ).toBe(true);
    expect(
      isConversationWorkspaceRoute({
        name: 'inbox_dashboard',
        path: '/app/accounts/1/inboxes/4',
      })
    ).toBe(true);
    expect(
      isConversationWorkspaceRoute({
        name: 'contacts_dashboard',
        path: '/app/accounts/1/contacts',
      })
    ).toBe(false);
  });

  it('activates the WhatsApp workspace only on conversation routes', () => {
    expect(
      shouldUseWhatsAppWorkspaceLayout(
        {},
        { channel_type: INBOX_TYPES.WHATSAPP },
        { name: 'home', path: '/app/accounts/1/conversations' }
      )
    ).toBe(true);
    expect(
      shouldUseWhatsAppWorkspaceLayout(
        {},
        { channel_type: INBOX_TYPES.WHATSAPP },
        { name: 'contacts_dashboard', path: '/app/accounts/1/contacts' }
      )
    ).toBe(false);
    expect(
      shouldUseWhatsAppWorkspaceLayout(
        {},
        { channel_type: INBOX_TYPES.EMAIL },
        { name: 'home', path: '/app/accounts/1/conversations' }
      )
    ).toBe(false);
  });
});
