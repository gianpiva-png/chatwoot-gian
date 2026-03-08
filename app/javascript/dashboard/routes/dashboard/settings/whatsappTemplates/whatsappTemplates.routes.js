import { frontendURL } from '../../../../helper/URLHelper';

import SettingsWrapper from '../SettingsWrapper.vue';
import Index from './Index.vue';
import TemplateDetails from './TemplateDetails.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/whatsapp-templates'),
      component: SettingsWrapper,
      children: [
        {
          path: '',
          name: 'whatsapp_templates_wrapper',
          meta: {
            permissions: ['administrator'],
          },
          redirect: to => {
            return { name: 'whatsapp_templates_list', params: to.params };
          },
        },
        {
          path: 'list',
          name: 'whatsapp_templates_list',
          meta: {
            permissions: ['administrator'],
          },
          component: Index,
        },
        {
          path: ':channelId/:templateName',
          name: 'whatsapp_template_details',
          meta: {
            permissions: ['administrator'],
          },
          component: TemplateDetails,
        },
      ],
    },
  ],
};
