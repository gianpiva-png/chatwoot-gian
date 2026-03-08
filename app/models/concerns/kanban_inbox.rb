# frozen_string_literal: true

# Custom concern for Kanban Board functionality on Inboxes
# This concern is kept separate to minimize merge conflicts with upstream Chatwoot
module KanbanInbox
  extend ActiveSupport::Concern

  included do
    has_many :kanban_stages, dependent: :destroy
  end

  def kanban_enabled?
    kanban_enabled
  end

  def setup_default_kanban_stages!
    return if kanban_stages.any?

    [
      { name: 'Novo', position: 0, is_default: true, color: '#1B83AC' },
      { name: 'Em Andamento', position: 1, color: '#F59E0B' },
      { name: 'Aguardando', position: 2, color: '#8B5CF6' },
      { name: 'Concluido', position: 3, is_closed: true, color: '#10B981' }
    ].each do |attrs|
      kanban_stages.create!(attrs.merge(account_id: account_id))
    end
  end
end
