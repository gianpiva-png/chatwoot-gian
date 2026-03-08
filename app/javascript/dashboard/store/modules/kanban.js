import types from '../mutation-types';
import KanbanAPI from '../../api/kanban';

export const state = {
  board: [],
  stages: [],
  currentInboxId: null,
  uiFlags: {
    isFetchingBoard: false,
    isFetchingStages: false,
    isMoving: false,
    isCreatingStage: false,
    isUpdatingStage: false,
    isDeletingStage: false,
  },
};

export const getters = {
  getBoard(_state) {
    return _state.board;
  },
  getStages(_state) {
    return _state.stages;
  },
  getCurrentInboxId(_state) {
    return _state.currentInboxId;
  },
  getUIFlags(_state) {
    return _state.uiFlags;
  },
};

export const actions = {
  fetchBoard: async function fetchBoard(
    { commit },
    { inboxId, filters = {} }
  ) {
    commit(types.SET_KANBAN_UI_FLAG, { isFetchingBoard: true });
    try {
      const response = await KanbanAPI.getBoard(inboxId, filters);
      commit(types.SET_KANBAN_BOARD, response.data.data);
      commit(types.SET_KANBAN_INBOX_ID, inboxId);
    } catch (error) {
      // Ignore error
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isFetchingBoard: false });
    }
  },

  moveConversation: async function moveConversation(
    { commit, state: _state },
    { inboxId, conversationId, fromStageId, toStageId }
  ) {
    // Optimistic update
    commit(types.MOVE_KANBAN_CONVERSATION, {
      conversationId,
      fromStageId,
      toStageId,
    });

    commit(types.SET_KANBAN_UI_FLAG, { isMoving: true });
    try {
      await KanbanAPI.moveConversation(inboxId, conversationId, toStageId);
    } catch (error) {
      // Revert on failure
      commit(types.MOVE_KANBAN_CONVERSATION, {
        conversationId,
        fromStageId: toStageId,
        toStageId: fromStageId,
      });
      throw new Error(error);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isMoving: false });
    }
  },

  fetchStages: async function fetchStages({ commit }, inboxId) {
    commit(types.SET_KANBAN_UI_FLAG, { isFetchingStages: true });
    try {
      const response = await KanbanAPI.getStages(inboxId);
      commit(types.SET_KANBAN_STAGES, response.data);
    } catch (error) {
      // Ignore error
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isFetchingStages: false });
    }
  },

  createStage: async function createStage({ commit }, { inboxId, stageData }) {
    commit(types.SET_KANBAN_UI_FLAG, { isCreatingStage: true });
    try {
      const response = await KanbanAPI.createStage(inboxId, stageData);
      commit(types.ADD_KANBAN_STAGE, response.data);
      return response.data;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isCreatingStage: false });
    }
  },

  updateStage: async function updateStage(
    { commit },
    { inboxId, stageId, stageData }
  ) {
    commit(types.SET_KANBAN_UI_FLAG, { isUpdatingStage: true });
    try {
      const response = await KanbanAPI.updateStage(
        inboxId,
        stageId,
        stageData
      );
      commit(types.EDIT_KANBAN_STAGE, response.data);
      return response.data;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isUpdatingStage: false });
    }
  },

  deleteStage: async function deleteStage({ commit }, { inboxId, stageId }) {
    commit(types.SET_KANBAN_UI_FLAG, { isDeletingStage: true });
    try {
      await KanbanAPI.deleteStage(inboxId, stageId);
      commit(types.DELETE_KANBAN_STAGE, stageId);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isDeletingStage: false });
    }
  },

  reorderStages: async function reorderStages(
    { commit },
    { inboxId, stages }
  ) {
    try {
      const response = await KanbanAPI.reorderStages(inboxId, stages);
      commit(types.SET_KANBAN_STAGES, response.data);
    } catch (error) {
      throw new Error(error);
    }
  },
};

export const mutations = {
  [types.SET_KANBAN_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },
  [types.SET_KANBAN_BOARD](_state, data) {
    _state.board = data;
  },
  [types.SET_KANBAN_INBOX_ID](_state, inboxId) {
    _state.currentInboxId = inboxId;
  },
  [types.SET_KANBAN_STAGES](_state, data) {
    _state.stages = data;
  },
  [types.ADD_KANBAN_STAGE](_state, stage) {
    _state.stages.push(stage);
  },
  [types.EDIT_KANBAN_STAGE](_state, updatedStage) {
    const index = _state.stages.findIndex(s => s.id === updatedStage.id);
    if (index !== -1) {
      _state.stages.splice(index, 1, updatedStage);
    }
  },
  [types.DELETE_KANBAN_STAGE](_state, stageId) {
    _state.stages = _state.stages.filter(s => s.id !== stageId);
  },
  [types.MOVE_KANBAN_CONVERSATION](_state, { conversationId, fromStageId, toStageId }) {
    const fromColumn = _state.board.find(
      col => col.stage.id === fromStageId
    );
    const toColumn = _state.board.find(col => col.stage.id === toStageId);

    if (fromColumn && toColumn) {
      const convIndex = fromColumn.conversations.findIndex(
        c => c.id === conversationId
      );
      if (convIndex !== -1) {
        const [conversation] = fromColumn.conversations.splice(convIndex, 1);
        toColumn.conversations.unshift(conversation);
        fromColumn.total_count -= 1;
        toColumn.total_count += 1;
      }
    }
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
