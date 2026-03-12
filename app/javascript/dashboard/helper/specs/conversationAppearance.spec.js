import {
  CONVERSATION_VISUAL_MODES,
  isWhatsAppConversationInbox,
  resolveConversationVisualMode,
  shouldUseWhatsAppConversationLayout,
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
});
