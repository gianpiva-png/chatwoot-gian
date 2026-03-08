/* global axios */
import ApiClient from './ApiClient';

class KanbanAPI extends ApiClient {
  constructor() {
    super('', { accountScoped: true });
  }

  getBoard(inboxId, filters = {}) {
    return axios.get(
      `${this.baseUrl()}/inboxes/${inboxId}/kanban`,
      { params: filters }
    );
  }

  moveConversation(inboxId, conversationId, stageId) {
    return axios.patch(
      `${this.baseUrl()}/inboxes/${inboxId}/kanban/move`,
      { conversation_id: conversationId, stage_id: stageId }
    );
  }

  getStages(inboxId) {
    return axios.get(
      `${this.baseUrl()}/inboxes/${inboxId}/kanban_stages`
    );
  }

  createStage(inboxId, data) {
    return axios.post(
      `${this.baseUrl()}/inboxes/${inboxId}/kanban_stages`,
      { kanban_stage: data }
    );
  }

  updateStage(inboxId, stageId, data) {
    return axios.patch(
      `${this.baseUrl()}/inboxes/${inboxId}/kanban_stages/${stageId}`,
      { kanban_stage: data }
    );
  }

  deleteStage(inboxId, stageId) {
    return axios.delete(
      `${this.baseUrl()}/inboxes/${inboxId}/kanban_stages/${stageId}`
    );
  }

  reorderStages(inboxId, stages) {
    return axios.post(
      `${this.baseUrl()}/inboxes/${inboxId}/kanban_stages/reorder`,
      { stages }
    );
  }
}

export default new KanbanAPI();
