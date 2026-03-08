# frozen_string_literal: true

# Custom concern for WhatsApp template visibility on Channel::Whatsapp
# This concern is kept separate to minimize merge conflicts with upstream Chatwoot
module WhatsappTemplateVisible
  extend ActiveSupport::Concern

  included do
    has_many :template_visibilities, class_name: 'WhatsappTemplateVisibility',
             foreign_key: :channel_whatsapp_id, dependent: :destroy
  end

  def visible_templates_for(assignable)
    visibility_names = template_visibilities.where(
      assignable_type: assignable.class.name,
      assignable_id: assignable.id
    ).pluck(:template_name)

    return message_templates if visibility_names.empty? && template_visibilities.empty?

    (message_templates || []).select { |t| visibility_names.include?(t['name']) }
  end
end
