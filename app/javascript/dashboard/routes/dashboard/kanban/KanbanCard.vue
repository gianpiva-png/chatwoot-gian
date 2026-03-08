<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { dynamicTime } from 'shared/helpers/timeHelper';

const props = defineProps({
  conversation: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['dragstart']);

const router = useRouter();
const { t } = useI18n();

const contact = computed(() => props.conversation.contact || {});
const assignee = computed(() => props.conversation.assignee);
const team = computed(() => props.conversation.team);
const displayId = computed(() => `#${props.conversation.display_id}`);

const priorityConfig = {
  0: { label: 'Low', class: 'bg-n-slate-2 text-n-slate-11' },
  1: { label: 'Medium', class: 'bg-n-amber-2 text-n-amber-11' },
  2: { label: 'High', class: 'bg-n-orange-2 text-n-orange-11' },
  3: { label: 'Urgent', class: 'bg-n-ruby-2 text-n-ruby-11' },
};

const priority = computed(() => {
  const p = props.conversation.priority;
  return p !== null && p !== undefined ? priorityConfig[p] : null;
});

const lastActivity = computed(() => {
  if (props.conversation.last_activity_at) {
    return dynamicTime(props.conversation.last_activity_at);
  }
  return '';
});

const contactInitial = computed(() => {
  const name = contact.value.name || '';
  return name.charAt(0).toUpperCase();
});

const onDragStart = event => {
  event.dataTransfer.setData(
    'text/plain',
    JSON.stringify({ conversationId: props.conversation.id })
  );
  event.dataTransfer.effectAllowed = 'move';
  emit('dragstart', props.conversation);
};

const openConversation = () => {
  router.push({
    name: 'inbox_conversation',
    params: { conversation_id: props.conversation.display_id },
  });
};
</script>

<template>
  <div
    draggable="true"
    class="p-3 bg-white dark:bg-n-solid-2 border border-n-weak rounded-lg cursor-grab
           hover:shadow-md transition-shadow active:cursor-grabbing select-none"
    @dragstart="onDragStart"
    @click="openConversation"
  >
    <!-- Header: ID + Priority -->
    <div class="flex items-center justify-between mb-2">
      <span class="text-xs font-mono text-n-slate-9">{{ displayId }}</span>
      <span
        v-if="priority"
        class="px-1.5 py-0.5 text-[10px] font-semibold rounded"
        :class="priority.class"
      >
        {{ priority.label }}
      </span>
    </div>

    <!-- Contact Info -->
    <div class="flex items-center gap-2 mb-2">
      <div
        v-if="contact.thumbnail"
        class="w-7 h-7 rounded-full bg-cover bg-center flex-shrink-0"
        :style="{ backgroundImage: `url(${contact.thumbnail})` }"
      />
      <div
        v-else
        class="w-7 h-7 rounded-full bg-n-brand flex-shrink-0 flex items-center justify-center text-white text-xs font-bold"
      >
        {{ contactInitial }}
      </div>
      <div class="min-w-0 flex-1">
        <p class="text-sm font-medium text-n-slate-12 truncate">
          {{ contact.name || t('KANBAN.CARD.UNKNOWN') }}
        </p>
        <p
          v-if="contact.phone_number"
          class="text-xs text-n-slate-9 truncate"
        >
          {{ contact.phone_number }}
        </p>
      </div>
    </div>

    <!-- Footer: Assignee + Time -->
    <div class="flex items-center justify-between pt-2 border-t border-n-weak">
      <div class="flex items-center gap-1">
        <template v-if="assignee">
          <div
            v-if="assignee.thumbnail"
            class="w-5 h-5 rounded-full bg-cover bg-center"
            :style="{ backgroundImage: `url(${assignee.thumbnail})` }"
          />
          <span class="text-xs text-n-slate-11 truncate max-w-[80px]">
            {{ assignee.name }}
          </span>
        </template>
        <span v-else class="text-xs text-n-slate-9 italic">
          {{ t('KANBAN.CARD.UNASSIGNED') }}
        </span>
      </div>
      <div class="flex items-center gap-2">
        <span
          v-if="team"
          class="px-1.5 py-0.5 text-[10px] rounded bg-n-alpha-2 text-n-slate-11"
        >
          {{ team.name }}
        </span>
        <span class="text-[10px] text-n-slate-9">{{ lastActivity }}</span>
      </div>
    </div>
  </div>
</template>
