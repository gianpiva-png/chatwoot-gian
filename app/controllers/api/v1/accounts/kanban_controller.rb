class Api::V1::Accounts::KanbanController < Api::V1::Accounts::BaseController
  before_action :check_authorization
  before_action :fetch_inbox

  def show
    stages = @inbox.kanban_stages.ordered
    board = stages.map do |stage|
      conversations = stage.conversations
                           .where(account_id: Current.account.id)
                           .includes(:contact, :assignee, :team)
                           .order(priority: :desc, last_activity_at: :desc)

      conversations = conversations.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
      conversations = conversations.where(team_id: params[:team_id]) if params[:team_id].present?
      conversations = conversations.where(priority: params[:priority]) if params[:priority].present?

      {
        stage: stage.as_json,
        conversations: conversations.limit(50).as_json(
          include: {
            contact: { only: [:id, :name, :email, :phone_number, :thumbnail] },
            assignee: { only: [:id, :name, :thumbnail] },
            team: { only: [:id, :name] }
          },
          methods: [:display_id]
        ),
        total_count: conversations.count
      }
    end

    render json: { data: board }
  end

  def move
    conversation = Current.account.conversations.find(params[:conversation_id])
    stage = @inbox.kanban_stages.find(params[:stage_id])

    conversation.update!(kanban_stage_id: stage.id)
    conversation.update!(status: :resolved) if stage.is_closed?

    render json: conversation.as_json(
      include: {
        contact: { only: [:id, :name, :email, :phone_number, :thumbnail] },
        assignee: { only: [:id, :name, :thumbnail] },
        team: { only: [:id, :name] }
      },
      methods: [:display_id]
    )
  end

  private

  def fetch_inbox
    @inbox = Current.account.inboxes.find(params[:inbox_id])
    render json: { error: 'Kanban is not enabled for this inbox' }, status: :unprocessable_entity unless @inbox.kanban_enabled?
  end
end
