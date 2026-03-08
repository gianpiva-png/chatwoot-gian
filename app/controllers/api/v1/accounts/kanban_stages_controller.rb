class Api::V1::Accounts::KanbanStagesController < Api::V1::Accounts::BaseController
  before_action :check_authorization
  before_action :fetch_inbox
  before_action :fetch_kanban_stage, only: [:update, :destroy]

  def index
    @stages = @inbox.kanban_stages.ordered
    render json: @stages
  end

  def create
    @stage = @inbox.kanban_stages.new(kanban_stage_params)
    @stage.account_id = Current.account.id
    @stage.save!
    render json: @stage, status: :created
  end

  def update
    @stage.update!(kanban_stage_params)
    render json: @stage
  end

  def destroy
    default_stage = @inbox.kanban_stages.default_stage.where.not(id: @stage.id).first
    @stage.conversations.update_all(kanban_stage_id: default_stage&.id) # rubocop:disable Rails/SkipsModelValidations
    @stage.destroy!
    head :no_content
  end

  def reorder
    params[:stages].each do |stage_data|
      KanbanStage.where(id: stage_data[:id], inbox_id: @inbox.id)
                 .update_all(position: stage_data[:position]) # rubocop:disable Rails/SkipsModelValidations
    end
    render json: @inbox.kanban_stages.ordered
  end

  private

  def fetch_inbox
    @inbox = Current.account.inboxes.find(params[:inbox_id])
  end

  def fetch_kanban_stage
    @stage = @inbox.kanban_stages.find(params[:id])
  end

  def kanban_stage_params
    params.require(:kanban_stage).permit(:name, :position, :color, :is_default, :is_closed)
  end
end
