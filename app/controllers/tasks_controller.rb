class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show]
  before_action :set_mytask, only: %i[edit update destroy update_assign edit_assign]
  before_action :set_q, only: %i[index mypage]

  def index
    @tasks = Task.incomplete.preload(:user).order(:title)
    @results = @q.result.incomplete.page(params[:page]).order(:title)
    gon.tasks = Task.select(:id, :title, :content).order(:title)
    gon.users = User.select(:id, :name).order(:name)
  end

  def mypage
    @tasks = current_user.tasks.incomplete.order(:title)
    gon.tasks = @tasks
    @results = @q.result.where(user_id: current_user.id).incomplete.page(params[:page]).order(:title)
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.new(task_params)
    if @task.save
      @task.send_slack
      redirect_to task_url(@task), notice: t('notice.task_create_success')
    else
      flash.now[:alert] = t('alert.task_create_failure')
      render :new
    end
  end

  def show
    @comment = Comment.new
    @comments = @task.comments.reverse_order.preload(:user).page(params[:page])
  end

  def edit;end

  def edit_assign
    @users = User.all
  end

  def update_assign
    if @task.update(user_id: params[:user_id])
      redirect_to task_url(@task), notice: t('notice.task_update_assign_success')
    else
      flash.now[:alert] = t('alert.task_update_assign_failure')
      render :edit_assign
    end
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task), notice: t('notice.task_update_success')
    else
      flash.now[:alert] = t('alert.task_update_failure')
      render :edit
    end
  end

  def destroy
    if @task.destroy
      redirect_to tasks_url, notice: t('notice.task_destroy_success')
    else
      flash.now[:alert] = t('alert.task_destroy_failure')
      render :index
    end
  end

  private

  def set_q
    @q = Task.preload(:user).ransack(params[:q])
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :deadline, :status)
  end

  def set_mytask
    @task = current_user.tasks.find_by(id: params[:id])
    redirect_to tasks_url, alert: t("alert.authorize_invalid") unless @task
  end
end
