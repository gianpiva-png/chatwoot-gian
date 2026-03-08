<script setup>
import { ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  inboxId: {
    type: [String, Number],
    required: true,
  },
  stages: {
    type: Array,
    default: () => [],
  },
});

const emit = defineEmits(['close', 'updated']);

const store = useStore();
const { t } = useI18n();

const localStages = ref([]);
const isSaving = ref(false);
const newStageName = ref('');

const initStages = () => {
  localStages.value = props.stages.map(s => ({ ...s }));
};

const addStage = () => {
  if (!newStageName.value.trim()) return;
  const maxPosition = localStages.value.reduce(
    (max, s) => Math.max(max, s.position),
    -1
  );
  localStages.value.push({
    id: null,
    name: newStageName.value.trim(),
    position: maxPosition + 1,
    color: '#94a3b8',
    is_default: false,
    is_closed: false,
    _isNew: true,
  });
  newStageName.value = '';
};

const removeStage = index => {
  const stage = localStages.value[index];
  if (stage.is_default) {
    useAlert(t('KANBAN.STAGES.CANNOT_DELETE_DEFAULT'));
    return;
  }
  localStages.value.splice(index, 1);
};

const setDefault = index => {
  localStages.value.forEach((s, i) => {
    s.is_default = i === index;
  });
};

const moveUp = index => {
  if (index === 0) return;
  const temp = localStages.value[index];
  localStages.value.splice(index, 1);
  localStages.value.splice(index - 1, 0, temp);
  reposition();
};

const moveDown = index => {
  if (index >= localStages.value.length - 1) return;
  const temp = localStages.value[index];
  localStages.value.splice(index, 1);
  localStages.value.splice(index + 1, 0, temp);
  reposition();
};

const reposition = () => {
  localStages.value.forEach((s, i) => {
    s.position = i;
  });
};

const saveStages = async () => {
  isSaving.value = true;
  try {
    // Create new stages
    for (const stage of localStages.value.filter(s => s._isNew)) {
      await store.dispatch('kanban/createStage', {
        inboxId: props.inboxId,
        stageData: {
          name: stage.name,
          position: stage.position,
          color: stage.color,
          is_default: stage.is_default,
          is_closed: stage.is_closed,
        },
      });
    }

    // Update existing stages
    for (const stage of localStages.value.filter(s => !s._isNew && s.id)) {
      await store.dispatch('kanban/updateStage', {
        inboxId: props.inboxId,
        stageId: stage.id,
        stageData: {
          name: stage.name,
          position: stage.position,
          color: stage.color,
          is_default: stage.is_default,
          is_closed: stage.is_closed,
        },
      });
    }

    // Delete removed stages
    const localIds = localStages.value.filter(s => s.id).map(s => s.id);
    for (const original of props.stages) {
      if (!localIds.includes(original.id)) {
        await store.dispatch('kanban/deleteStage', {
          inboxId: props.inboxId,
          stageId: original.id,
        });
      }
    }

    useAlert(t('KANBAN.STAGES.SAVE_SUCCESS'));
    emit('updated');
  } catch (error) {
    useAlert(t('KANBAN.STAGES.SAVE_ERROR'));
  } finally {
    isSaving.value = false;
  }
};

onMounted(() => {
  initStages();
});
</script>

<template>
  <div class="flex flex-col w-full max-w-lg p-6">
    <h2 class="text-lg font-semibold text-n-slate-12 mb-1">
      {{ $t('KANBAN.STAGES.TITLE') }}
    </h2>
    <p class="text-sm text-n-slate-11 mb-4">
      {{ $t('KANBAN.STAGES.DESCRIPTION') }}
    </p>

    <!-- Stages List -->
    <div class="space-y-2 mb-4 max-h-80 overflow-y-auto">
      <div
        v-for="(stage, index) in localStages"
        :key="stage.id || `new-${index}`"
        class="flex items-center gap-2 p-3 border rounded-lg border-n-weak bg-n-background"
      >
        <!-- Move Buttons -->
        <div class="flex flex-col gap-0.5">
          <button
            class="text-n-slate-9 hover:text-n-slate-12 text-xs"
            :disabled="index === 0"
            @click="moveUp(index)"
          >
            ▲
          </button>
          <button
            class="text-n-slate-9 hover:text-n-slate-12 text-xs"
            :disabled="index >= localStages.length - 1"
            @click="moveDown(index)"
          >
            ▼
          </button>
        </div>

        <!-- Color -->
        <input
          v-model="stage.color"
          type="color"
          class="w-7 h-7 rounded border border-n-weak cursor-pointer flex-shrink-0"
        />

        <!-- Name -->
        <input
          v-model="stage.name"
          type="text"
          class="flex-1 text-sm border rounded px-2 py-1.5 border-n-weak bg-n-background text-n-slate-12"
          :placeholder="$t('KANBAN.STAGES.NAME')"
        />

        <!-- Toggles -->
        <label class="flex items-center gap-1 text-xs text-n-slate-11 whitespace-nowrap cursor-pointer">
          <input
            type="radio"
            :checked="stage.is_default"
            name="default_stage"
            @change="setDefault(index)"
          />
          {{ $t('KANBAN.STAGES.DEFAULT') }}
        </label>

        <label class="flex items-center gap-1 text-xs text-n-slate-11 whitespace-nowrap cursor-pointer">
          <input
            v-model="stage.is_closed"
            type="checkbox"
          />
          {{ $t('KANBAN.STAGES.CLOSED') }}
        </label>

        <!-- Delete -->
        <button
          class="text-n-slate-9 hover:text-n-ruby-11 flex-shrink-0"
          @click="removeStage(index)"
        >
          <span class="text-sm">✕</span>
        </button>
      </div>
    </div>

    <!-- Add Stage -->
    <div class="flex gap-2 mb-4">
      <input
        v-model="newStageName"
        type="text"
        class="flex-1 text-sm border rounded px-2 py-1.5 border-n-weak bg-n-background text-n-slate-12"
        :placeholder="$t('KANBAN.STAGES.ADD_PLACEHOLDER')"
        @keyup.enter="addStage"
      />
      <Button
        :label="$t('KANBAN.STAGES.ADD')"
        size="sm"
        slate
        @click="addStage"
      />
    </div>

    <!-- Actions -->
    <div class="flex justify-end gap-2 pt-4 border-t border-n-weak">
      <Button
        :label="$t('KANBAN.STAGES.CANCEL')"
        slate
        size="sm"
        @click="emit('close')"
      />
      <Button
        :label="$t('KANBAN.STAGES.SAVE')"
        size="sm"
        :is-loading="isSaving"
        @click="saveStages"
      />
    </div>
  </div>
</template>
