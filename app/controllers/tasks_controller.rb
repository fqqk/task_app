class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy assign update_assign]
  before_action :is_authorized_user?, only: %i[ edit update destroy assign update_assign]
  before_action :authenticate_user!

  def index
    if params[:new]
      @tasks = Task.latest.page(params[:page])
    elsif params[:old]
      @tasks = Task.old.page(params[:page])
    elsif params[:emergency]
      @tasks = Task.emergency.page(params[:page])
    else
     @tasks = Task.not_complete.page(params[:page])
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
      @mytasks = current_user.tasks.not_complete.page(params[:page])
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
      redirect_to task_url(@task), notice: t(".notice")
    else
      render :new, alert: t(".alert")
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
      redirect_to task_url(@task), notice: t(".notice")
    else
      render :index, alert: t(".alert")
    end
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task), notice: t(".notice")
    else
      render :edit, alert: t(".alert")
    end
  end

  def destroy
    if @task.destroy
      redirect_to tasks_url, notice: t(".notice")
    else
      render task_url, alert: t(".alert")
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
    redirect_to root_url, alert: t(".alert") unless @tasks.exists?(id: params[:id])
  end
end
