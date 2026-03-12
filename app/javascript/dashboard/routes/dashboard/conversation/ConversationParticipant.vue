<script>
import Spinner from 'shared/components/Spinner.vue';
import { useAlert } from 'dashboard/composables';
import { mapGetters } from 'vuex';
import { useAgentsList } from 'dashboard/composables/useAgentsList';

import ThumbnailGroup from 'dashboard/components/widgets/ThumbnailGroup.vue';
import MultiselectDropdownItems from 'shared/components/ui/MultiselectDropdownItems.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    Spinner,
    ThumbnailGroup,
    MultiselectDropdownItems,
    NextButton,
  },
  props: {
    conversationId: {
      type: [Number, String],
      required: true,
    },
    isWhatsAppLayout: {
      type: Boolean,
      default: false,
    },
  },
  setup() {
    const { agentsList } = useAgentsList(false);
    return {
      agentsList,
    };
  },
  data() {
    return {
      selectedWatchers: [],
      showDropDown: false,
    };
  },
  computed: {
    ...mapGetters({
      watchersUiFlas: 'conversationWatchers/getUIFlags',
      currentUser: 'getCurrentUser',
    }),
    watchersFromStore() {
      return this.$store.getters['conversationWatchers/getByConversationId'](
        this.conversationId
      );
    },
    watchersList: {
      get() {
        return this.selectedWatchers;
      },
      set(participants) {
        this.selectedWatchers = [...participants];
        const userIds = participants.map(el => el.id);
        this.updateParticipant(userIds);
      },
    },
    isUserWatching() {
      return this.selectedWatchers.some(
        watcher => watcher.id === this.currentUser.id
      );
    },
    thumbnailList() {
      return this.selectedWatchers.slice(0, 4);
    },
    moreAgentCount() {
      const maxThumbnailCount = 4;
      return this.watchersList.length - maxThumbnailCount;
    },
    moreThumbnailsText() {
      if (this.moreAgentCount > 1) {
        return this.$t('CONVERSATION_PARTICIPANTS.REMANING_PARTICIPANTS_TEXT', {
          count: this.moreAgentCount,
        });
      }
      return this.$t('CONVERSATION_PARTICIPANTS.REMANING_PARTICIPANT_TEXT', {
        count: 1,
      });
    },
    showMoreThumbs() {
      return this.moreAgentCount > 0;
    },
    totalWatchersText() {
      if (this.selectedWatchers.length > 1) {
        return this.$t('CONVERSATION_PARTICIPANTS.TOTAL_PARTICIPANTS_TEXT', {
          count: this.selectedWatchers.length,
        });
      }
      return this.$t('CONVERSATION_PARTICIPANTS.TOTAL_PARTICIPANT_TEXT', {
        count: 1,
      });
    },
  },
  watch: {
    conversationId() {
      this.fetchParticipants();
    },
    watchersFromStore(participants = []) {
      this.selectedWatchers = [...participants];
    },
  },
  mounted() {
    this.fetchParticipants();
    this.$store.dispatch('agents/get');
  },
  methods: {
    fetchParticipants() {
      const conversationId = this.conversationId;
      this.$store.dispatch('conversationWatchers/show', { conversationId });
    },
    async updateParticipant(userIds) {
      const conversationId = this.conversationId;
      let alertMessage = this.$t(
        'CONVERSATION_PARTICIPANTS.API.SUCCESS_MESSAGE'
      );

      try {
        await this.$store.dispatch('conversationWatchers/update', {
          conversationId,
          userIds,
        });
      } catch (error) {
        alertMessage =
          error?.message ||
          this.$t('CONVERSATION_PARTICIPANTS.API.ERROR_MESSAGE');
      } finally {
        useAlert(alertMessage);
      }
      this.fetchParticipants();
    },
    onOpenDropdown() {
      this.showDropDown = true;
    },
    onCloseDropdown() {
      this.showDropDown = false;
    },
    onClickItem(agent) {
      const isAgentSelected = this.watchersList.some(
        participant => participant.id === agent.id
      );

      if (isAgentSelected) {
        const updatedList = this.watchersList.filter(
          participant => participant.id !== agent.id
        );

        this.watchersList = [...updatedList];
      } else {
        this.watchersList = [...this.watchersList, agent];
      }
    },
    onSelfAssign() {
      this.watchersList = [...this.selectedWatchers, this.currentUser];
    },
  },
};
</script>

<template>
  <div
    class="conversation-participant relative"
    :class="isWhatsAppLayout ? 'conversation-participant--whatsapp' : ''"
  >
    <div class="flex justify-between">
      <div class="flex justify-between w-full mb-1">
        <div>
          <p
            v-if="watchersList.length"
            class="m-0 text-sm total-watchers"
            :class="isWhatsAppLayout ? 'font-medium text-[#111b21]' : ''"
          >
            <Spinner v-if="watchersUiFlas.isFetching" size="tiny" />
            {{ totalWatchersText }}
          </p>
          <p
            v-else
            class="m-0 text-sm"
            :class="isWhatsAppLayout ? 'text-[#667781]' : 'text-n-slate-10'"
          >
            {{ $t('CONVERSATION_PARTICIPANTS.NO_PARTICIPANTS_TEXT') }}
          </p>
        </div>
        <NextButton
          v-tooltip.left="$t('CONVERSATION_PARTICIPANTS.ADD_PARTICIPANTS')"
          slate
          ghost
          sm
          icon="i-lucide-settings"
          class="relative -top-1"
          :class="isWhatsAppLayout ? 'conversation-participant__settings' : ''"
          :title="$t('CONVERSATION_PARTICIPANTS.ADD_PARTICIPANTS')"
          @click="onOpenDropdown"
        />
      </div>
    </div>
    <div class="flex items-center justify-between">
      <ThumbnailGroup
        :more-thumbnails-text="moreThumbnailsText"
        :show-more-thumbnails-count="showMoreThumbs"
        :users-list="thumbnailList"
        :size="isWhatsAppLayout ? 28 : 24"
        :gap="isWhatsAppLayout ? 'tight' : 'normal'"
      />
      <p
        v-if="isUserWatching"
        class="m-0 text-sm"
        :class="isWhatsAppLayout ? 'text-[#667781]' : 'text-n-slate-10'"
      >
        {{ $t('CONVERSATION_PARTICIPANTS.YOU_ARE_WATCHING') }}
      </p>
      <NextButton
        v-else
        link
        xs
        icon="i-lucide-arrow-right"
        class="!gap-1"
        :class="isWhatsAppLayout ? 'conversation-participant__watch-link' : ''"
        :label="$t('CONVERSATION_PARTICIPANTS.WATCH_CONVERSATION')"
        @click="onSelfAssign"
      />
    </div>
    <div
      v-on-clickaway="
        () => {
          onCloseDropdown();
        }
      "
      class="absolute box-border top-8 w-full p-2 z-[9999]"
      :class="[
        {
          'block visible': showDropDown,
          'hidden invisible': !showDropDown,
        },
        isWhatsAppLayout
          ? 'rounded-2xl border border-[#dfe5e7] bg-white shadow-[0_12px_32px_rgba(17,27,33,0.12)]'
          : 'border rounded-lg shadow-lg bg-n-alpha-3 backdrop-blur-[100px] border-n-strong dark:border-n-strong',
      ]"
    >
      <div class="flex items-center justify-between mb-1">
        <h4
          class="m-0 overflow-hidden text-sm whitespace-nowrap text-ellipsis"
          :class="isWhatsAppLayout ? 'text-[#111b21]' : 'text-n-slate-12'"
        >
          {{ $t('CONVERSATION_PARTICIPANTS.ADD_PARTICIPANTS') }}
        </h4>
        <NextButton
          ghost
          slate
          xs
          icon="i-lucide-x"
          :class="isWhatsAppLayout ? 'conversation-participant__close' : ''"
          @click="onCloseDropdown"
        />
      </div>
      <MultiselectDropdownItems
        :options="agentsList"
        :selected-items="selectedWatchers"
        has-thumbnail
        @select="onClickItem"
      />
    </div>
  </div>
</template>

<style scoped lang="scss">
.conversation-participant--whatsapp {
  @apply rounded-2xl border border-[#e3e6e8] bg-[#f7f8fa] p-3;

  :deep(.conversation-participant__settings button),
  :deep(.conversation-participant__close button) {
    @apply rounded-full border-0 text-[#54656f];
    background-color: #ffffff;
  }

  :deep(.conversation-participant__settings button:hover),
  :deep(.conversation-participant__close button:hover) {
    background-color: #f0f2f5;
  }

  :deep(.conversation-participant__watch-link button) {
    @apply text-[#008069];
  }
}
</style>
