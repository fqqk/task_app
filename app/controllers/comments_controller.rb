class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ edit update destroy ]
  before_action :set_task, only: %i[ create destroy edit ]

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      redirect_back fallback_location: root_path, notice: t(".notice")
    else
      @comments = @task.comments.reverse_order.page(params[:page])
      redirect_to task_url(@task), alert: t(".alert")
    end
  end

  def edit
  end


  def update
    if @comment.update(comment_params)
      redirect_to task_url(@comment.task_id), notice: t(".notice")
    else
      redirect_to task_url(@comment.task_id), alert: t(".alert")
    end
  end

  def destroy
    if @comment.destroy
      redirect_to task_url(@task), notice: t(".notice")
    else
      redirect_to task_url(@task), notice: t(".alert")
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_comment
    @comment = Comment.find_by(id:params[:id], task_id: params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:comment, :task_id)
  end
end
