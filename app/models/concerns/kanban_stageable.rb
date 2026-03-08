# frozen_string_literal: true

# Custom concern for Kanban Board functionality on Conversations
# This concern is kept separate to minimize merge conflicts with upstream Chatwoot
module KanbanStageable
  extend ActiveSupport::Concern

  included do
    belongs_to :kanban_stage, optional: true

    after_create_commit :assign_default_kanban_stage
    after_update_commit :sync_kanban_stage_from_status, if: -> { saved_change_to_status? && inbox&.kanban_enabled? }
  end

  private

  def assign_default_kanban_stage
    return unless inbox&.kanban_enabled?

    default_stage = inbox.kanban_stages.default_stage.first
    # rubocop:disable Rails/SkipsModelValidations
    update_column(:kanban_stage_id, default_stage.id) if default_stage
    # rubocop:enable Rails/SkipsModelValidations
  end

  def sync_kanban_stage_from_status
    if resolved?
      closed_stage = inbox.kanban_stages.find_by(is_closed: true)
      # rubocop:disable Rails/SkipsModelValidations
      update_column(:kanban_stage_id, closed_stage.id) if closed_stage
      # rubocop:enable Rails/SkipsModelValidations
    elsif open? && kanban_stage&.is_closed?
      default_stage = inbox.kanban_stages.default_stage.first
      # rubocop:disable Rails/SkipsModelValidations
      update_column(:kanban_stage_id, default_stage.id) if default_stage
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
