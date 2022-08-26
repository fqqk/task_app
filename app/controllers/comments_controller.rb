class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ edit update destroy ]
  before_action :set_task, only: %i[ create destroy edit ]

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      redirect_back fallback_location: root_path, notice: t(".notice")
      # _urlか_pathか統一をお願いします。
      # t(".notice")だと分かり辛いので、t('notice.comment_create_success')のような形で呼び出せるように修正
      # 以下のnoticeやalertも同様
    else
      @comments = @task.comments.reverse_order.page(params[:page])
      redirect_to task_url(@task), alert: t(".alert")
    end
  end

  def edit; end

  def update
    if @comment.update(comment_params)
      redirect_to task_url(@comment), notice: t(".notice")
    else
      redirect_to task_url(@comment), alert: t(".alert")
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
    @comment = Comment.find(id: params[:id], task_id: params[:task_id])
    #find_byだとエラーをハンドリングしてくれるがfindだと該当のidがない場合にエラー発生
    #今回の場合はエラーを出してあげていいと思います。
  end

  def comment_params
    params.require(:comment).permit(:comment, :task_id)
  end
end
