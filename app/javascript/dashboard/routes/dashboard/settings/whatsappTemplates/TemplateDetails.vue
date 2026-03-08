<script setup>
import { computed, onBeforeMount, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStoreGetters, useStore } from 'dashboard/composables/store';
import { useRoute, useRouter } from 'vue-router';

import VisibilityEditor from './VisibilityEditor.vue';
import SettingsLayout from '../SettingsLayout.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import { useAlert } from 'dashboard/composables';

const getters = useStoreGetters();
const store = useStore();
const route = useRoute();
const router = useRouter();
const { t } = useI18n();

const showVisibilityModal = ref(false);

const records = computed(
  () => getters['whatsappTemplates/getWhatsappTemplates'].value
);
const uiFlags = computed(
  () => getters['whatsappTemplates/getUIFlags'].value
);
const inboxes = computed(() => getters['inboxes/getInboxes'].value);
const teams = computed(() => getters['teams/getTeams'].value);
const whatsappInboxes = computed(() =>
  inboxes.value.filter(i => i.channel_type === 'Channel::Whatsapp')
);

const template = computed(() => {
  const channelId = Number(route.params.channelId);
  const name = route.params.templateName;
  return records.value.find(
    t => t.channel_whatsapp_id === channelId && t.name === name
  );
});

const statusBadgeClass = computed(() => {
  const classes = {
    APPROVED: 'bg-n-teal-2 text-n-teal-11',
    PENDING: 'bg-n-amber-2 text-n-amber-11',
    REJECTED: 'bg-n-ruby-2 text-n-ruby-11',
  };
  return classes[template.value?.status] || 'bg-n-slate-2 text-n-slate-11';
});

const headerComponent = computed(() => {
  if (!template.value?.components) return null;
  return template.value.components.find(c => c.type === 'HEADER');
});

const bodyComponent = computed(() => {
  if (!template.value?.components) return null;
  return template.value.components.find(c => c.type === 'BODY');
});

const footerComponent = computed(() => {
  if (!template.value?.components) return null;
  return template.value.components.find(c => c.type === 'FOOTER');
});

const buttonsComponent = computed(() => {
  if (!template.value?.components) return null;
  return template.value.components.find(c => c.type === 'BUTTONS');
});

const highlightParams = text => {
  if (!text) return '';
  return text.replace(
    /\{\{(\d+)\}\}/g,
    '<span class="bg-n-amber-2 text-n-amber-11 px-1 rounded font-mono text-xs">{{$1}}</span>'
  );
};

const goBack = () => {
  router.push({ name: 'whatsapp_templates_list' });
};

const onVisibilitySaved = () => {
  showVisibilityModal.value = false;
  store.dispatch('whatsappTemplates/get');
  useAlert(t('WHATSAPP_TEMPLATES.VISIBILITY.SAVE_SUCCESS'));
};

onBeforeMount(() => {
  if (!records.value.length) {
    store.dispatch('whatsappTemplates/get');
  }
  store.dispatch('inboxes/get');
  store.dispatch('teams/get');
});
</script>

<template>
  <SettingsLayout
    :is-loading="uiFlags.isFetching"
    :no-records-found="!template"
    :no-records-message="$t('WHATSAPP_TEMPLATES.DETAILS.NOT_FOUND')"
  >
    <template #header>
      <BaseSettingsHeader
        :title="template?.name || $t('WHATSAPP_TEMPLATES.DETAILS.TITLE')"
        :description="$t('WHATSAPP_TEMPLATES.DETAILS.SUBTITLE')"
        feature-name="whatsapp-templates"
      >
        <template #actions>
          <div class="flex gap-2">
            <Button
              :label="$t('WHATSAPP_TEMPLATES.BACK_TO_LIST')"
              size="sm"
              slate
              icon="i-lucide-arrow-left"
              @click="goBack"
            />
            <Button
              v-if="template"
              :label="$t('WHATSAPP_TEMPLATES.MANAGE_VISIBILITY')"
              size="sm"
              icon="i-lucide-shield"
              @click="showVisibilityModal = true"
            />
          </div>
        </template>
      </BaseSettingsHeader>
    </template>
    <template #body>
      <div v-if="template" class="p-6 space-y-6">
        <!-- Template Info -->
        <div
          class="flex items-center gap-4 p-4 border rounded-lg border-n-weak bg-n-background"
        >
          <div class="flex-1 space-y-1">
            <h3 class="text-lg font-semibold text-n-slate-12">
              {{ template.name }}
            </h3>
            <div class="flex items-center gap-3 text-sm text-n-slate-11">
              <span>{{ template.inbox_name || template.phone_number }}</span>
              <span>·</span>
              <span>{{ template.language }}</span>
              <span>·</span>
              <span
                class="px-2 py-0.5 text-xs font-medium rounded-full"
                :class="statusBadgeClass"
              >
                {{ template.status }}
              </span>
            </div>
          </div>
        </div>

        <!-- Components -->
        <div class="space-y-4">
          <h4 class="text-sm font-semibold text-n-slate-12 uppercase tracking-wide">
            {{ $t('WHATSAPP_TEMPLATES.DETAILS.COMPONENTS') }}
          </h4>

          <!-- Header -->
          <div
            v-if="headerComponent"
            class="p-4 border rounded-lg border-n-weak"
          >
            <div
              class="text-xs font-semibold text-n-slate-11 uppercase mb-2"
            >
              {{ $t('WHATSAPP_TEMPLATES.DETAILS.HEADER') }}
            </div>
            <div
              v-if="headerComponent.format === 'TEXT'"
              class="text-sm text-n-slate-12"
              v-html="highlightParams(headerComponent.text)"
            />
            <div
              v-else
              class="text-sm text-n-slate-11 italic"
            >
              {{ headerComponent.format }} {{ $t('WHATSAPP_TEMPLATES.DETAILS.MEDIA_TYPE') }}
            </div>
          </div>

          <!-- Body -->
          <div
            v-if="bodyComponent"
            class="p-4 border rounded-lg border-n-weak"
          >
            <div
              class="text-xs font-semibold text-n-slate-11 uppercase mb-2"
            >
              {{ $t('WHATSAPP_TEMPLATES.DETAILS.BODY') }}
            </div>
            <div
              class="text-sm text-n-slate-12 whitespace-pre-wrap"
              v-html="highlightParams(bodyComponent.text)"
            />
          </div>

          <!-- Footer -->
          <div
            v-if="footerComponent"
            class="p-4 border rounded-lg border-n-weak"
          >
            <div
              class="text-xs font-semibold text-n-slate-11 uppercase mb-2"
            >
              {{ $t('WHATSAPP_TEMPLATES.DETAILS.FOOTER') }}
            </div>
            <div class="text-sm text-n-slate-11">
              {{ footerComponent.text }}
            </div>
          </div>

          <!-- Buttons -->
          <div
            v-if="buttonsComponent"
            class="p-4 border rounded-lg border-n-weak"
          >
            <div
              class="text-xs font-semibold text-n-slate-11 uppercase mb-2"
            >
              {{ $t('WHATSAPP_TEMPLATES.DETAILS.BUTTONS') }}
            </div>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="(btn, idx) in buttonsComponent.buttons"
                :key="idx"
                class="px-3 py-1.5 text-sm border rounded-lg border-n-weak bg-n-alpha-1 text-n-slate-12"
              >
                {{ btn.text }}
                <span class="text-xs text-n-slate-9 ml-1">
                  ({{ btn.type }})
                </span>
              </span>
            </div>
          </div>
        </div>

        <!-- Visibility -->
        <div class="space-y-3">
          <h4
            class="text-sm font-semibold text-n-slate-12 uppercase tracking-wide"
          >
            {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.TITLE') }}
          </h4>
          <div
            v-if="
              !template.visibilities || template.visibilities.length === 0
            "
            class="text-sm text-n-slate-11"
          >
            {{ $t('WHATSAPP_TEMPLATES.VISIBILITY.ALL_VISIBLE') }}
          </div>
          <div v-else class="flex flex-wrap gap-2">
            <span
              v-for="(vis, idx) in template.visibilities"
              :key="idx"
              class="px-2 py-1 text-xs rounded-full bg-n-alpha-2 text-n-slate-11"
            >
              {{ vis.assignable_type }}: #{{ vis.assignable_id }}
            </span>
          </div>
        </div>
      </div>
    </template>

    <woot-modal
      v-if="template"
      v-model:show="showVisibilityModal"
      :on-close="() => (showVisibilityModal = false)"
    >
      <VisibilityEditor
        :template="template"
        :inboxes="whatsappInboxes"
        :teams="teams"
        @close="showVisibilityModal = false"
        @saved="onVisibilitySaved"
      />
    </woot-modal>
  </SettingsLayout>
</template>
