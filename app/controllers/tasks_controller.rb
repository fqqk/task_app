class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]
  before_action :authenticate_user!
  def index
    @tasks = Task.all
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.create(task_params)
    if @task.save
      redirect_to task_url(@blog), notice: '新しいタスクを登録しました！'
    else
      render :new, alert: "タスクの登録に失敗しました。やり直してください"
    end
  end

  def show

  end

  def edit
  end

  def destroy
    if @task.destroy
      redirect_to tasks_url, notice: "ブログを削除しました"
    else
      render task_url, alert: "ブログの削除に失敗しました"
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :deadline, :status)
  end
end
