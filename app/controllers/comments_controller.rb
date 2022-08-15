class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ edit update destroy ]
  before_action :set_task, only: %i[ destroy ]

  def create
    comment = current_user.comments.new(comment_params)
    if comment.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'Comment was successfully created.' }
        format.json { head :no_content }
      end
    else
      redirect_to root_path
    end
  end

  def edit

  end


  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to task_url(@comment.task_id), notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @comment.destroy
      respond_to do |format|
        format.html { redirect_to task_path(@task), notice: 'Comment was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to root_path
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
