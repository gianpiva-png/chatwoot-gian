import { frontendURL } from '../../../helper/URLHelper';
import KanbanView from './KanbanView.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/kanban/inbox/:inbox_id'),
      name: 'kanban_board',
      component: KanbanView,
      props: route => ({
        inboxId: route.params.inbox_id,
      }),
      meta: {
        permissions: ['administrator', 'agent'],
      },
    },
  ],
};
