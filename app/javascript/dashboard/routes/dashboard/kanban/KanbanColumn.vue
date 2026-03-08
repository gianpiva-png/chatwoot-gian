<script setup>
import { ref } from 'vue';
import KanbanCard from './KanbanCard.vue';

const props = defineProps({
  stage: {
    type: Object,
    required: true,
  },
  conversations: {
    type: Array,
    default: () => [],
  },
  totalCount: {
    type: Number,
    default: 0,
  },
});

const emit = defineEmits(['drop', 'load-more']);

const isDragOver = ref(false);

const onDragOver = event => {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';
  isDragOver.value = true;
};

const onDragLeave = () => {
  isDragOver.value = false;
};

const onDrop = event => {
  event.preventDefault();
  isDragOver.value = false;
  try {
    const data = JSON.parse(event.dataTransfer.getData('text/plain'));
    emit('drop', {
      conversationId: data.conversationId,
      targetStageId: props.stage.id,
    });
  } catch {
    // ignore invalid drag data
  }
};

const hasMore = () => props.totalCount > props.conversations.length;
</script>

<template>
  <div
    class="flex flex-col w-72 min-w-[288px] flex-shrink-0 bg-n-background rounded-xl border border-n-weak"
    :class="{ 'ring-2 ring-n-brand ring-opacity-50': isDragOver }"
    @dragover="onDragOver"
    @dragleave="onDragLeave"
    @drop="onDrop"
  >
    <!-- Column Header -->
    <div class="flex items-center justify-between p-3 border-b border-n-weak">
      <div class="flex items-center gap-2">
        <span
          class="w-3 h-3 rounded-full flex-shrink-0"
          :style="{ backgroundColor: stage.color || '#94a3b8' }"
        />
        <h3 class="text-sm font-semibold text-n-slate-12 truncate">
          {{ stage.name }}
        </h3>
      </div>
      <span
        class="flex items-center justify-center min-w-[24px] h-6 px-1.5 text-xs font-semibold rounded-full bg-n-alpha-2 text-n-slate-11"
      >
        {{ totalCount }}
      </span>
    </div>

    <!-- Cards -->
    <div
      class="flex-1 overflow-y-auto p-2 space-y-2 min-h-[100px]"
      :class="{ 'bg-n-alpha-1': isDragOver }"
    >
      <KanbanCard
        v-for="conversation in conversations"
        :key="conversation.id"
        :conversation="conversation"
      />

      <div
        v-if="conversations.length === 0"
        class="flex items-center justify-center h-20 text-sm text-n-slate-9 italic"
      >
        {{ $t('KANBAN.CARD.NO_CONVERSATIONS') }}
      </div>

      <button
        v-if="hasMore()"
        class="w-full py-2 text-xs text-center text-n-brand hover:bg-n-alpha-1 rounded"
        @click="emit('load-more', stage.id)"
      >
        {{ $t('KANBAN.LOAD_MORE') }} ({{ totalCount - conversations.length }})
      </button>
    </div>
  </div>
</template>
