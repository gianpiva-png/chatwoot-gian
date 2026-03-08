<script setup>
import { useAlert } from 'dashboard/composables';
import { computed, onBeforeMount, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStoreGetters, useStore } from 'dashboard/composables/store';
import { useRouter } from 'vue-router';
import { picoSearch } from '@scmmishra/pico-search';

import VisibilityEditor from './VisibilityEditor.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import SettingsLayout from '../SettingsLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import {
  BaseTable,
  BaseTableRow,
  BaseTableCell,
} from 'dashboard/components-next/table';

const getters = useStoreGetters();
const store = useStore();
const router = useRouter();
const { t } = useI18n();

const searchQuery = ref('');
const statusFilter = ref('');
const showVisibilityModal = ref(false);
const selectedTemplate = ref(null);

const records = computed(() => getters['whatsappTemplates/getWhatsappTemplates'].value);
const uiFlags = computed(() => getters['whatsappTemplates/getUIFlags'].value);
const inboxes = computed(() => getters['inboxes/getInboxes'].value);
const teams = computed(() => getters['teams/getTeams'].value);

const whatsappInboxes = computed(() =>
  inboxes.value.filter(i => i.channel_type === 'Channel::Whatsapp')
);

const filteredRecords = computed(() => {
  let templates = records.value;
  if (statusFilter.value) {
    templates = templates.filter(t => t.status === statusFilter.value);
  }
  const query = searchQuery.value.trim();
  if (!query) return templates;
  return picoSearch(templates, query, [
    { name: 'name', weight: 4 },
    'language',
  ]);
});

const tableHeaders = computed(() => [
  t('WHATSAPP_TEMPLATES.TABLE.NAME'),
  t('WHATSAPP_TEMPLATES.TABLE.INBOX'),
  t('WHATSAPP_TEMPLATES.TABLE.STATUS'),
  t('WHATSAPP_TEMPLATES.TABLE.LANGUAGE'),
  t('WHATSAPP_TEMPLATES.TABLE.VISIBILITY'),
  t('WHATSAPP_TEMPLATES.TABLE.ACTIONS'),
]);

const statusBadgeClass = status => {
  const classes = {
    APPROVED: 'bg-n-teal-2 text-n-teal-11',
    PENDING: 'bg-n-amber-2 text-n-amber-11',
    REJECTED: 'bg-n-ruby-2 text-n-ruby-11',
  };
  return classes[status] || 'bg-n-slate-2 text-n-slate-11';
};

const visibilityCount = template => {
  if (!template.visibilities || template.visibilities.length === 0) {
    return t('WHATSAPP_TEMPLATES.VISIBILITY.ALL_VISIBLE');
  }
  return `${template.visibilities.length} ${t('WHATSAPP_TEMPLATES.VISIBILITY.ASSIGNED')}`;
};

const openVisibilityEditor = template => {
  selectedTemplate.value = template;
  showVisibilityModal.value = true;
};

const closeVisibilityEditor = () => {
  showVisibilityModal.value = false;
  selectedTemplate.value = null;
};

const viewDetails = template => {
  router.push({
    name: 'whatsapp_template_details',
    params: {
      channelId: template.channel_whatsapp_id,
      templateName: template.name,
    },
  });
};

const syncTemplates = async () => {
  try {
    await store.dispatch('whatsappTemplates/sync');
    useAlert(t('WHATSAPP_TEMPLATES.SYNC_SUCCESS'));
    setTimeout(() => {
      store.dispatch('whatsappTemplates/get');
    }, 3000);
  } catch (error) {
    useAlert(t('WHATSAPP_TEMPLATES.SYNC_ERROR'));
  }
};

const onVisibilitySaved = () => {
  closeVisibilityEditor();
  store.dispatch('whatsappTemplates/get');
  useAlert(t('WHATSAPP_TEMPLATES.VISIBILITY.SAVE_SUCCESS'));
};

onBeforeMount(() => {
  store.dispatch('whatsappTemplates/get');
  store.dispatch('inboxes/get');
  store.dispatch('teams/get');
});
</script>

<template>
  <SettingsLayout
    :is-loading="uiFlags.isFetching"
    :loading-message="$t('WHATSAPP_TEMPLATES.LOADING')"
    :no-records-found="!records.length"
    :no-records-message="$t('WHATSAPP_TEMPLATES.NO_RECORDS')"
  >
    <template #header>
      <BaseSettingsHeader
        v-model:search-query="searchQuery"
        :title="$t('WHATSAPP_TEMPLATES.HEADER')"
        :description="$t('WHATSAPP_TEMPLATES.DESCRIPTION')"
        :search-placeholder="$t('WHATSAPP_TEMPLATES.SEARCH_PLACEHOLDER')"
        feature-name="whatsapp-templates"
      >
        <template v-if="records?.length" #count>
          <span class="text-body-main text-n-slate-11">
            {{ records.length }} {{ $t('WHATSAPP_TEMPLATES.TEMPLATES_COUNT') }}
          </span>
        </template>
        <template #actions>
          <div class="flex items-center gap-2">
            <select
              v-model="statusFilter"
              class="h-8 text-sm border rounded border-n-weak bg-n-background px-2"
            >
              <option value="">
                {{ $t('WHATSAPP_TEMPLATES.ALL_STATUSES') }}
              </option>
              <option value="APPROVED">APPROVED</option>
              <option value="PENDING">PENDING</option>
              <option value="REJECTED">REJECTED</option>
            </select>
            <Button
              :label="$t('WHATSAPP_TEMPLATES.SYNC_ALL')"
              size="sm"
              :is-loading="uiFlags.isSyncing"
              icon="i-lucide-refresh-cw"
              @click="syncTemplates"
            />
          </div>
        </template>
      </BaseSettingsHeader>
    </template>
    <template #body>
      <BaseTable
        :headers="tableHeaders"
        :items="filteredRecords"
        :no-data-message="
          searchQuery
            ? $t('WHATSAPP_TEMPLATES.NO_RESULTS')
            : $t('WHATSAPP_TEMPLATES.NO_RECORDS')
        "
      >
        <template #row="{ items }">
          <BaseTableRow
            v-for="template in items"
            :key="`${template.channel_whatsapp_id}-${template.name}`"
            :item="template"
          >
            <template #default>
              <BaseTableCell>
                <span class="text-body-main text-n-slate-12 font-medium">
                  {{ template.name }}
                </span>
              </BaseTableCell>

              <BaseTableCell>
                <span class="text-body-main text-n-slate-11">
                  {{ template.inbox_name || template.phone_number }}
                </span>
              </BaseTableCell>

              <BaseTableCell>
                <span
                  class="px-2 py-0.5 text-xs font-medium rounded-full"
                  :class="statusBadgeClass(template.status)"
                >
                  {{ template.status }}
                </span>
              </BaseTableCell>

              <BaseTableCell>
                <span class="text-body-main text-n-slate-11">
                  {{ template.language }}
                </span>
              </BaseTableCell>

              <BaseTableCell>
                <span class="text-body-main text-n-slate-11">
                  {{ visibilityCount(template) }}
                </span>
              </BaseTableCell>

              <BaseTableCell align="end">
                <div class="flex gap-2 justify-end flex-shrink-0">
                  <Button
                    v-tooltip.top="$t('WHATSAPP_TEMPLATES.VIEW_DETAILS')"
                    icon="i-lucide-eye"
                    slate
                    sm
                    @click="viewDetails(template)"
                  />
                  <Button
                    v-tooltip.top="$t('WHATSAPP_TEMPLATES.MANAGE_VISIBILITY')"
                    icon="i-lucide-shield"
                    slate
                    sm
                    @click="openVisibilityEditor(template)"
                  />
                </div>
              </BaseTableCell>
            </template>
          </BaseTableRow>
        </template>
      </BaseTable>
    </template>

    <woot-modal
      v-model:show="showVisibilityModal"
      :on-close="closeVisibilityEditor"
    >
      <VisibilityEditor
        v-if="selectedTemplate"
        :template="selectedTemplate"
        :inboxes="whatsappInboxes"
        :teams="teams"
        @close="closeVisibilityEditor"
        @saved="onVisibilitySaved"
      />
    </woot-modal>
  </SettingsLayout>
</template>
