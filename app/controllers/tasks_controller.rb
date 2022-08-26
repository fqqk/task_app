class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy assign update_assign]
  before_action :is_authorized_user?, only: %i[ edit update destroy assign update_assign]
  before_action :authenticate_user!
  before_action :set_q, only: [ :index, :search, :mypage ]

  def index
    @tasks = Task.where.not(status:"complete").page(params[:page])
    gon.tasks = Task.all.preload(:user)
  end

  def mypage
    if params[:new]
      @mytasks = current_user.tasks.latest.page(params[:page])
    elsif params[:old]
      @mytasks = current_user.tasks.old.page(params[:page])
    elsif params[:emergency]
      @mytasks = current_user.tasks.emergency.page(params[:page])
    else
      @mytasks = current_user.tasks.where.not(status: "complete").page(params[:page])
    end
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id
    if @task.save
      @task.send_slack
      redirect_to task_url(@task), notice: t(".create_comment_success")
    else
      redirect_to new_task_url, alert: t(".create_comment_failure")
    end
  end

  def show
    @comment = Comment.new
    @comments = @task.comments.reverse_order.page(params[:page]).per(5)
  end

  def edit
  end

  def assign
    @users = User.all
  end

  def update_assign
    if @task.update(user_id:params[:task][:user_id])
      redirect_to task_url(@task), notice: t(".update_assign_comment_success")
    else
      redirect_to tasks_url, alert: t(".update_assign_comment_failure")
    end
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task), notice: t(".update_comment_success")
    else
      redirect_to task_url(@task), alert: t(".update_comment_failure")
    end
  end

  def destroy
    if @task.destroy
      redirect_to tasks_url, notice: t(".destory_comment_success")
    else
      redirect_to tasks_url, alert: t(".destroy_comment_failure")
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

  def is_authorized_user?
    @tasks = current_user.tasks
    redirect_to tasks_url, alert: t(".alert") unless @tasks.exists?(id: params[:id])
  end
end
