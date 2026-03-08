import types from '../mutation-types';
import WhatsappTemplatesAPI from '../../api/whatsappTemplates';

export const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isSyncing: false,
    isUpdatingVisibility: false,
  },
};

export const getters = {
  getWhatsappTemplates(_state) {
    return _state.records;
  },
  getUIFlags(_state) {
    return _state.uiFlags;
  },
};

export const actions = {
  get: async function get({ commit }, params = {}) {
    commit(types.SET_WHATSAPP_TEMPLATE_UI_FLAG, { isFetching: true });
    try {
      const response = await WhatsappTemplatesAPI.getAll(params);
      commit(types.SET_WHATSAPP_TEMPLATES, response.data.data);
    } catch (error) {
      // Ignore error
    } finally {
      commit(types.SET_WHATSAPP_TEMPLATE_UI_FLAG, { isFetching: false });
    }
  },

  sync: async function sync({ commit }, channelWhatsappId = null) {
    commit(types.SET_WHATSAPP_TEMPLATE_UI_FLAG, { isSyncing: true });
    try {
      await WhatsappTemplatesAPI.sync(channelWhatsappId);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_WHATSAPP_TEMPLATE_UI_FLAG, { isSyncing: false });
    }
  },

  updateVisibilities: async function updateVisibilities(
    { commit },
    { channelWhatsappId, templateName, visibilities }
  ) {
    commit(types.SET_WHATSAPP_TEMPLATE_UI_FLAG, { isUpdatingVisibility: true });
    try {
      await WhatsappTemplatesAPI.updateVisibilities(
        channelWhatsappId,
        templateName,
        visibilities
      );
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_WHATSAPP_TEMPLATE_UI_FLAG, {
        isUpdatingVisibility: false,
      });
    }
  },
};

export const mutations = {
  [types.SET_WHATSAPP_TEMPLATE_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },
  [types.SET_WHATSAPP_TEMPLATES](_state, data) {
    _state.records = data;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
