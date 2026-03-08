<script setup>
import { computed, onBeforeMount, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStoreGetters, useStore } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';

import KanbanColumn from './KanbanColumn.vue';
import StageManager from './StageManager.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  inboxId: {
    type: [String, Number],
    required: true,
  },
});

const getters = useStoreGetters();
const store = useStore();
const { t } = useI18n();

const showStageManager = ref(false);
const assigneeFilter = ref('');
const teamFilter = ref('');
const priorityFilter = ref('');

const board = computed(() => getters['kanban/getBoard'].value);
const stages = computed(() => getters['kanban/getStages'].value);
const uiFlags = computed(() => getters['kanban/getUIFlags'].value);
const agents = computed(() => getters['agents/getAgents'].value);
const teams = computed(() => getters['teams/getTeams'].value);

const inboxes = computed(() => getters['inboxes/getInboxes'].value);
const currentInbox = computed(() =>
  inboxes.value.find(i => String(i.id) === String(props.inboxId))
);

const filters = computed(() => {
  const f = {};
  if (assigneeFilter.value) f.assignee_id = assigneeFilter.value;
  if (teamFilter.value) f.team_id = teamFilter.value;
  if (priorityFilter.value) f.priority = priorityFilter.value;
  return f;
});

const fetchBoard = () => {
  store.dispatch('kanban/fetchBoard', {
    inboxId: props.inboxId,
    filters: filters.value,
  });
};

const fetchStages = () => {
  store.dispatch('kanban/fetchStages', props.inboxId);
};

const onDrop = async ({ conversationId, targetStageId }) => {
  // Find the source stage
  const sourceColumn = board.value.find(col =>
    col.conversations.some(c => c.id === conversationId)
  );
  if (!sourceColumn || sourceColumn.stage.id === targetStageId) return;

  try {
    await store.dispatch('kanban/moveConversation', {
      inboxId: props.inboxId,
      conversationId,
      fromStageId: sourceColumn.stage.id,
      toStageId: targetStageId,
    });
  } catch (error) {
    useAlert(t('KANBAN.MOVE_ERROR'));
  }
};

const onStagesUpdated = () => {
  showStageManager.value = false;
  fetchStages();
  fetchBoard();
};

watch(filters, () => {
  fetchBoard();
});

onBeforeMount(() => {
  fetchBoard();
  fetchStages();
  store.dispatch('agents/get');
  store.dispatch('teams/get');
  store.dispatch('inboxes/get');
});
</script>

<template>
  <div class="flex flex-col h-full bg-n-background">
    <!-- Header -->
    <div
      class="flex items-center justify-between px-6 py-4 border-b border-n-weak flex-shrink-0"
    >
      <div>
        <h1 class="text-xl font-semibold text-n-slate-12">
          {{ currentInbox?.name || '' }} — {{ $t('KANBAN.TITLE') }}
        </h1>
      </div>
      <div class="flex items-center gap-3">
        <!-- Filters -->
        <select
          v-model="assigneeFilter"
          class="h-8 text-sm border rounded border-n-weak bg-n-background px-2 text-n-slate-12"
        >
          <option value="">
            {{ $t('KANBAN.FILTERS.ALL_AGENTS') }}
          </option>
          <option
            v-for="agent in agents"
            :key="agent.id"
            :value="agent.id"
          >
            {{ agent.name }}
          </option>
        </select>

        <select
          v-model="teamFilter"
          class="h-8 text-sm border rounded border-n-weak bg-n-background px-2 text-n-slate-12"
        >
          <option value="">
            {{ $t('KANBAN.FILTERS.ALL_TEAMS') }}
          </option>
          <option
            v-for="team in teams"
            :key="team.id"
            :value="team.id"
          >
            {{ team.name }}
          </option>
        </select>

        <select
          v-model="priorityFilter"
          class="h-8 text-sm border rounded border-n-weak bg-n-background px-2 text-n-slate-12"
        >
          <option value="">
            {{ $t('KANBAN.FILTERS.ALL_PRIORITIES') }}
          </option>
          <option value="0">Low</option>
          <option value="1">Medium</option>
          <option value="2">High</option>
          <option value="3">Urgent</option>
        </select>

        <Button
          :label="$t('KANBAN.MANAGE_STAGES')"
          size="sm"
          slate
          icon="i-lucide-settings"
          @click="showStageManager = true"
        />

        <Button
          icon="i-lucide-refresh-cw"
          size="sm"
          slate
          :is-loading="uiFlags.isFetchingBoard"
          @click="fetchBoard"
        />
      </div>
    </div>

    <!-- Board -->
    <div class="flex-1 overflow-x-auto overflow-y-hidden p-4">
      <div
        v-if="uiFlags.isFetchingBoard && !board.length"
        class="flex items-center justify-center h-full"
      >
        <span class="text-n-slate-11">{{ $t('KANBAN.LOADING') }}</span>
      </div>
      <div
        v-else-if="board.length === 0"
        class="flex items-center justify-center h-full"
      >
        <div class="text-center">
          <p class="text-n-slate-11 mb-2">
            {{ $t('KANBAN.NO_STAGES') }}
          </p>
          <Button
            :label="$t('KANBAN.MANAGE_STAGES')"
            size="sm"
            @click="showStageManager = true"
          />
        </div>
      </div>
      <div v-else class="flex gap-4 h-full">
        <KanbanColumn
          v-for="column in board"
          :key="column.stage.id"
          :stage="column.stage"
          :conversations="column.conversations"
          :total-count="column.total_count"
          @drop="onDrop"
        />
      </div>
    </div>

    <!-- Stage Manager Modal -->
    <woot-modal
      v-model:show="showStageManager"
      :on-close="() => (showStageManager = false)"
    >
      <StageManager
        :inbox-id="props.inboxId"
        :stages="stages"
        @close="showStageManager = false"
        @updated="onStagesUpdated"
      />
    </woot-modal>
  </div>
</template>
