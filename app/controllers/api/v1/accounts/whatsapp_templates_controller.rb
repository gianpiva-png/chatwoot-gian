class Api::V1::Accounts::WhatsappTemplatesController < Api::V1::Accounts::BaseController
  before_action :check_authorization

  def index
    templates = []
    whatsapp_channels.each do |channel|
      next if channel.message_templates.blank?

      inbox = channel.inbox
      channel.message_templates.each do |template|
        templates << {
          channel_whatsapp_id: channel.id,
          inbox_id: inbox&.id,
          inbox_name: inbox&.name,
          phone_number: channel.phone_number,
          name: template['name'],
          namespace: template['namespace'],
          status: template['status'],
          language: template['language'],
          category: template['category'],
          components: template['components'],
          visibilities: template_visibilities_for(channel, template['name'])
        }
      end
    end

    templates = filter_templates(templates)
    render json: { data: templates }
  end

  def sync
    channels = if params[:channel_whatsapp_id]
                 [Channel::Whatsapp.where(account_id: Current.account.id).find(params[:channel_whatsapp_id])]
               else
                 whatsapp_channels
               end

    channels.each do |channel|
      Channels::Whatsapp::TemplatesSyncJob.perform_later(channel)
    end

    render json: { message: 'Template sync initiated' }
  end

  def update_visibilities
    ActiveRecord::Base.transaction do
      WhatsappTemplateVisibility.where(
        account_id: Current.account.id,
        channel_whatsapp_id: params[:channel_whatsapp_id],
        template_name: params[:template_name]
      ).destroy_all

      (params[:visibilities] || []).each do |visibility|
        WhatsappTemplateVisibility.create!(
          account_id: Current.account.id,
          channel_whatsapp_id: params[:channel_whatsapp_id],
          template_name: params[:template_name],
          assignable_type: visibility[:assignable_type],
          assignable_id: visibility[:assignable_id]
        )
      end
    end

    render json: { message: 'Visibilities updated successfully' }
  end

  private

  def whatsapp_channels
    @whatsapp_channels ||= Channel::Whatsapp.where(account_id: Current.account.id).includes(:inbox)
  end

  def template_visibilities_for(channel, template_name)
    channel.template_visibilities.where(template_name: template_name).map do |v|
      { assignable_type: v.assignable_type, assignable_id: v.assignable_id }
    end
  end

  def filter_templates(templates)
    templates = templates.select { |t| t[:name]&.downcase&.include?(params[:search].downcase) } if params[:search].present?
    templates = templates.select { |t| t[:status] == params[:status] } if params[:status].present?
    if params[:channel_whatsapp_id].present?
      templates = templates.select do |t|
        t[:channel_whatsapp_id].to_s == params[:channel_whatsapp_id].to_s
      end
    end
    templates
  end
end
