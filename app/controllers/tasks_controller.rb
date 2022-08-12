class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy assign update_assign]
  before_action :is_authorized_user?, only: %i[ edit update destroy assign update_assign]
  before_action :authenticate_user!

  def index
    if params[:new]
      @tasks = Task.not_complete.latest.page(params[:page]).limit(6)
    elsif params[:old]
      @tasks = Task.not_complete.old.page(params[:page]).limit(6)
    elsif params[:emergency]
      @tasks = Task.not_complete.emergency.page(params[:page]).limit(6)
    else
     @tasks = Task.not_complete.page(params[:page]).limit(6)
    end
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user_id = current_user.id
    client = Slack::Web::Client.new
    if @task.save
      client.chat_postMessage(
        channel: '#実験場所',
        blocks: [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "#{@task.user.name}さんがタスクの新規作成を行いました:fire:"
            }
          },
          {
            "type": "header",
            "text": {
              "type": "plain_text",
              "text": "生成されたタスク↓",
              "emoji": true
            }
          },
          {
            "type": "actions",
            "elements": [
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "#{@task.title}"
                },
                "style": "primary",
                "url": "http://localhost:8080/tasks/#{@task.id}"
              },
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "コメントする"
                },
                "url": "https://news.google.co.jp/"
              }
            ]
          }
        ]
      )
      redirect_to task_url(@task), notice: t(".notice")
    else
      render :new, alert: t(".alert")
    end
  end

  def show
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
