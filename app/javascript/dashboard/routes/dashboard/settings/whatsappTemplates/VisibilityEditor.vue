<script setup>
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from 'dashboard/composables/store';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  template: {
    type: Object,
    required: true,
  },
  inboxes: {
    type: Array,
    default: () => [],
  },
  teams: {
    type: Array,
    default: () => [],
  },
});

const emit = defineEmits(['close', 'saved']);

const store = useStore();
const { t } = useI18n();

const selectedInboxIds = ref([]);
const selectedTeamIds = ref([]);
const isSaving = ref(false);

const currentInboxVisibilities = computed(() =>
  (props.template.visibilities || []).filter(
    v => v.assignable_type === 'Inbox'
  )
);

const currentTeamVisibilities = computed(() =>
  (props.template.visibilities || []).filter(
    v => v.assignable_type === 'Team'
  )
);

const toggleInbox = inboxId => {
  const idx = selectedInboxIds.value.indexOf(inboxId);
  if (idx === -1) {
    selectedInboxIds.value.push(inboxId);
  } else {
    selectedInboxIds.value.splice(idx, 1);
  }
};

const toggleTeam = teamId => {
  const idx = selectedTeamIds.value.indexOf(teamId);
  if (idx === -1) {
    selectedTeamIds.value.push(teamId);
  } else {
    selectedTeamIds.value.splice(idx, 1);
  }
};

const saveVisibilities = async () => {
  isSaving.value = true;
  try {
    const visibilities = [
      ...selectedInboxIds.value.map(id => ({
        assignable_type: 'Inbox',
        assignable_id: id,
      })),
      ...selectedTeamIds.value.map(id => ({
        assignable_type: 'Team',
        assignable_id: id,
      })),
    ];

    await store.dispatch('whatsappTemplates/updateVisibilities', {
      channelWhatsappId: props.template.channel_whatsapp_id,
      templateName: props.template.name,
      visibilities,
    });
    emit('saved');
  } catch (error) {
    // handled by store
  } finally {
    isSaving.value = false;
  }
};

onMounted(() => {
  selectedInboxIds.value = currentInboxVisibilities.value.map(
    v => v.assignable_id
  );
  selectedTeamIds.value = currentTeamVisibilities.value.map(
    v => v.assignable_id
  );
});
</script>

<template>
  <div class="flex flex-col w-full max-w-lg p-6">
    <h2 class="text-lg font-semibold text-n-slate-12 mb-1">
      {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.TITLE') }}
    </h2>
    <p class="text-sm text-n-slate-11 mb-4">
      {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.DESCRIPTION') }}
      <strong>{{ template.name }}</strong>
    </p>

    <!-- Info -->
    <div
      v-if="selectedInboxIds.length === 0 && selectedTeamIds.length === 0"
      class="p-3 mb-4 text-sm rounded-lg bg-n-amber-1 text-n-amber-11 border border-n-amber-6"
    >
      {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.ALL_VISIBLE_INFO') }}
    </div>

    <!-- Inboxes Section -->
    <div class="mb-6">
      <h3 class="text-sm font-semibold text-n-slate-12 mb-2">
        {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.INBOXES') }}
      </h3>
      <div
        v-if="inboxes.length === 0"
        class="text-sm text-n-slate-9 italic"
      >
        {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.NO_WHATSAPP_INBOXES') }}
      </div>
      <div v-else class="space-y-2 max-h-48 overflow-y-auto">
        <label
          v-for="inbox in inboxes"
          :key="`inbox-${inbox.id}`"
          class="flex items-center gap-2 p-2 rounded-lg cursor-pointer hover:bg-n-alpha-1"
        >
          <input
            type="checkbox"
            :checked="selectedInboxIds.includes(inbox.id)"
            class="rounded border-n-weak"
            @change="toggleInbox(inbox.id)"
          />
          <span class="text-sm text-n-slate-12">{{ inbox.name }}</span>
          <span
            v-if="inbox.phone_number"
            class="text-xs text-n-slate-9"
          >
            ({{ inbox.phone_number }})
          </span>
        </label>
      </div>
    </div>

    <!-- Teams Section -->
    <div class="mb-6">
      <h3 class="text-sm font-semibold text-n-slate-12 mb-2">
        {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.TEAMS') }}
      </h3>
      <div
        v-if="teams.length === 0"
        class="text-sm text-n-slate-9 italic"
      >
        {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.NO_TEAMS') }}
      </div>
      <div v-else class="space-y-2 max-h-48 overflow-y-auto">
        <label
          v-for="team in teams"
          :key="`team-${team.id}`"
          class="flex items-center gap-2 p-2 rounded-lg cursor-pointer hover:bg-n-alpha-1"
        >
          <input
            type="checkbox"
            :checked="selectedTeamIds.includes(team.id)"
            class="rounded border-n-weak"
            @change="toggleTeam(team.id)"
          />
          <span class="text-sm text-n-slate-12">{{ team.name }}</span>
        </label>
      </div>
    </div>

    <!-- Actions -->
    <div class="flex justify-end gap-2 pt-4 border-t border-n-weak">
      <Button
        :label="$t('WHATSAPP_TEMPLATES.VISIBILITY.CANCEL')"
        slate
        size="sm"
        @click="emit('close')"
      />
      <Button
        :label="$t('WHATSAPP_TEMPLATES.VISIBILITY.SAVE')"
        size="sm"
        :is-loading="isSaving"
        @click="saveVisibilities"
      />
    </div>
  </div>
</template>
