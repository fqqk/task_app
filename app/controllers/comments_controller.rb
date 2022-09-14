class CommentsController < ApplicationController
  before_action :set_comment, only: %i[edit update destroy]
  before_action :set_task, only: %i[create destroy edit update]

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      redirect_back fallback_location: root_url, notice: t('notice.comment_create_success')
    else
      flash[:alert] = t('alert.comment_create_failure')
      redirect_back fallback_location: root_path
    end
  end

  def edit;end


  def update
    if @comment.update(comment_params)
      flash[:notice] = t('notice.comment_update_success')
      redirect_to task_url(@task)
    else
      flash[:alert] = t('alert.comment_update_failure')
      render :edit
    end
  end

  def destroy
    if @comment.destroy
      redirect_to task_url(@task), notice: t('notice.comment_destroy_success')
    else
      flash.now[:alert] = t('alert.comment_destroy_failure')
      redirect_back fallback_location: root_path
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_comment
    @comment = current_user.comments.find_by(id: params[:id], task_id: params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:comment, :task_id)
  end
end
