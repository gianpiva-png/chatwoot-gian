/* global axios */
import ApiClient from './ApiClient';

class WhatsappTemplatesAPI extends ApiClient {
  constructor() {
    super('whatsapp_templates', { accountScoped: true });
  }

  getAll(params = {}) {
    return axios.get(this.url, { params });
  }

  sync(channelWhatsappId = null) {
    return axios.post(`${this.url}/sync`, {
      channel_whatsapp_id: channelWhatsappId,
    });
  }

  updateVisibilities(channelWhatsappId, templateName, visibilities) {
    return axios.post(`${this.url}/update_visibilities`, {
      channel_whatsapp_id: channelWhatsappId,
      template_name: templateName,
      visibilities,
    });
  }
}

export default new WhatsappTemplatesAPI();
