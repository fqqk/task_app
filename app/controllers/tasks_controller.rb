class TasksController < ApplicationController
  before_action :set_task, only: %i[show]
  before_action :set_mytask, only: %i[edit update destroy update_assign edit_assign]
  before_action :authenticate_user!
  before_action :set_q, only: %i[index search mypage]

  def index
    @tasks = Task.where.not(status:'complete').page(params[:page])
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
      redirect_to task_url(@task), notice: t('.notice.task_create_success')
    else
      redirect_to new_task_url, alert: t('.alert.task_create_failure')
    end
  end

  def show
    @comment = Comment.new
    @comments = @task.comments.reverse_order.page(params[:page])
  end

  def edit;end

  def edit_assign
    @users = User.all
  end

  def update_assign
    if @task.update(user_id: params[:user_id])
      redirect_to task_url(@task), notice: t('.notice.update_assign_comment_success')
    else
      redirect_to tasks_url, alert: t('.alert.update_assign_comment_failure')
    end
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task), notice: t('.notice.task_update_success')
    else
      redirect_to task_url(@task), alert: t('.alert.task_update_failure')
    end
  end

  def destroy
    if @task.destroy
      redirect_to tasks_url, notice: t('.notice.task_destroy_success')
    else
      redirect_to tasks_url, alert: t('.alert.task_destroy_failure')
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
    redirect_to tasks_url, alert: t(".alert.authorize_invalid") unless @task
  end
end
