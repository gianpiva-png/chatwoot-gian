class AddKanbanStageIdToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :kanban_stage_id, :bigint
    add_index :conversations, :kanban_stage_id
    add_foreign_key :conversations, :kanban_stages
  end
end
