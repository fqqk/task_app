class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ edit update destroy ]
  before_action :set_task, only: %i[ create destroy edit ]

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      redirect_back fallback_location: root_url, notice: t('.create_comment_success')
    else
      @comments = @task.comments.reverse_order.page(params[:page])
      redirect_to task_url(@task), alert: t('.create_comment_failure')
    end
  end

  def edit;end


  def update
    if @comment.update(comment_params)
      redirect_to task_url(@comment), notice: t('.update_comment_success')
    else
      redirect_to task_url(@comment), alert: t('.update_comment_failure')
    end
  end

  def destroy
    if @comment.destroy
      redirect_to task_url(@task), notice: t('.destroy_comment_success')
    else
      redirect_to task_url(@task), notice: t('.destroy_comment_failure')
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_comment
    @comment = Comment.find(id:params[:id], task_id: params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:comment, :task_id)
  end
end
