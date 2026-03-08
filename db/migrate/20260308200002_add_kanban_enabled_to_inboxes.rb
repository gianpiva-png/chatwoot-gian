class AddKanbanEnabledToInboxes < ActiveRecord::Migration[7.0]
  def change
    add_column :inboxes, :kanban_enabled, :boolean, default: false
  end
end
