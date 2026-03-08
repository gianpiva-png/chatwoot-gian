# == Schema Information
#
# Table name: whatsapp_template_visibilities
#
#  id                  :bigint           not null, primary key
#  assignable_type     :string           not null
#  template_language   :string
#  template_name       :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :bigint           not null
#  assignable_id       :bigint           not null
#  channel_whatsapp_id :bigint           not null
#

class WhatsappTemplateVisibility < ApplicationRecord
  belongs_to :account
  belongs_to :channel_whatsapp, class_name: 'Channel::Whatsapp'
  belongs_to :assignable, polymorphic: true

  validates :template_name, presence: true
  validates :template_name, uniqueness: {
    scope: [:channel_whatsapp_id, :assignable_type, :assignable_id]
  }

  scope :for_inbox, ->(inbox_id) { where(assignable_type: 'Inbox', assignable_id: inbox_id) }
  scope :for_team, ->(team_id) { where(assignable_type: 'Team', assignable_id: team_id) }
  scope :for_template, ->(name) { where(template_name: name) }
end
