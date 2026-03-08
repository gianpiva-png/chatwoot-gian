# == Schema Information
#
# Table name: kanban_stages
#
#  id         :bigint           not null, primary key
#  color      :string
#  is_closed  :boolean          default(FALSE)
#  is_default :boolean          default(FALSE)
#  name       :string           not null
#  position   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  inbox_id   :bigint           not null
#

class KanbanStage < ApplicationRecord
  belongs_to :account
  belongs_to :inbox
  has_many :conversations, dependent: :nullify

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :name, uniqueness: { scope: :inbox_id }

  scope :ordered, -> { order(position: :asc) }
  scope :default_stage, -> { where(is_default: true) }

  after_save :ensure_single_default, if: :is_default?

  private

  def ensure_single_default
    KanbanStage.where(inbox_id: inbox_id, is_default: true)
               .where.not(id: id)
               .update_all(is_default: false) # rubocop:disable Rails/SkipsModelValidations
  end
end
