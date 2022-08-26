class TasksController < ApplicationController
  before_action :set_task, only: %i[show]
  before_action :set_my_task, only: %i[ edit update destroy assign update_assign]
  before_action :authenticate_user!
  before_action :set_q, only: [ :index, :search, :mypage ]

  def index
    # 口頭確認 ransackを使って実装できないか
    # includeやpreloadなどを使ってuserもまとめて取っておいた方がいいです。
    # view側でsql発行すると処理が遅くなってしまうので。
    if params[:new]
      @tasks = Task.latest.page(params[:page])
    elsif params[:old]
      @tasks = Task.old.page(params[:page])
    elsif params[:emergency]
      @tasks = Task.emergency.page(params[:page])
    else
      # 基本シングルクォーテーション
     @tasks = Task.where.not(status: 'complete').page(params[:page])
    end
  end

  def mypage
    if params[:new]
      @mytasks = current_user.tasks.latest.page(params[:page])
    elsif params[:old]
      @mytasks = current_user.tasks.old.page(params[:page])
    elsif params[:emergency]
      @mytasks = current_user.tasks.emergency.page(params[:page])
    else
      @mytasks = current_user.tasks.where.not(status: 'complete').page(params[:page])
    end
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      @task.send_slack
      redirect_to task_url(@task), notice: t(".notice")
    else
      redirect_to new_task_url, alert: t(".alert")
    end
  end

  def show
    @comment = Comment.new
    # ここだけ５件表示にしている理由を教えてください。
    @comments = @task.comments.reverse_order.page(params[:page]).per(5)
  end

  def edit
  end

  def edit_assign
    @users = User.all
  end

  def update_assign
    if @task.update(user_id: params[:task][:user_id])
      redirect_to task_url(@task), notice: t(".notice")
    else
      redirect_to tasks_url, alert: t(".alert")
    end
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task), notice: t(".notice")
    else
      redirect_to task_url(@task), alert: t(".alert")
    end
  end

  def destroy
    if @task.destroy
      redirect_to tasks_url, notice: t(".notice")
    else
      redirect_to tasks_url, alert: t(".alert")
    end
  end

  def search
    @results = @q.result
  end

  private

  def set_q
    @q = Task.ransack(params[:q])
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :deadline, :status)
  end

  def set_mytask
    @task = current_user.tasks.find(params[:id])
    redirect_to tasks_url, alert: t(".alert") unless @task
  end
end
