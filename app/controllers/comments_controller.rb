class CommentsController < ApplicationController
  before_action :set_comment, only: %i[edit update destroy]
  before_action :set_task, only: %i[create destroy edit]

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      redirect_back fallback_location: root_url, notice: t('notice.comment_create_success')
    else
      @comments = @task.comments.reverse_order.page(params[:page])
      redirect_to task_url(@task), alert: t('alert.comment_create_failure')
    end
  end

  def edit;end


  def update
    if @comment.update(comment_params)
      redirect_to task_url(@comment), notice: t('notice.comment_update_success')
    else
      redirect_to task_url(@comment), alert: t('alert.comment_update_failure')
    end
  end

  def destroy
    if @comment.destroy
      redirect_to task_url(@task), notice: t('notice.comment_destroy_success')
    else
      redirect_to task_url(@task), notice: t('alert.comment_destroy_failure')
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_comment
    @comment = Comment.find(id: params[:id], task_id: params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:comment, :task_id)
  end
end
