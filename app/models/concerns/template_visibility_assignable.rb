# frozen_string_literal: true

# Custom concern for WhatsApp template visibility on Inboxes and Teams
# This concern is kept separate to minimize merge conflicts with upstream Chatwoot
module TemplateVisibilityAssignable
  extend ActiveSupport::Concern

  included do
    has_many :template_visibilities, as: :assignable,
             class_name: 'WhatsappTemplateVisibility', dependent: :destroy
  end
end
