class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]
  before_action :is_authorized_user?, only: %i[ edit update destroy assign ]
  before_action :authenticate_user!
  def index
    @tasks = Task.not_complete
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id
    if @task.save
      redirect_to task_url(@task), notice: '新しいタスクを登録しました！'
    else
      render :new, alert: "タスクの登録に失敗しました。やり直してください"
    end
  end

  def show
  end

  def edit
  end

  def assign
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task), notice: 'タスクの編集をしました'
    else
      render :edit, alert: 'タスクの編集に失敗しました。やり直してください'
    end
  end

  def destroy
    if @task.destroy
      redirect_to tasks_url, notice: "タスクを削除しました"
    else
      render task_url, alert: "タスクの削除に失敗しました"
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :deadline, :status)
  end

  def is_authorized_user?
    @tasks = current_user.tasks
    redirect_to root_url, alert: '権限がありません' unless @tasks.exists?(id: params[:id])
  end
end
