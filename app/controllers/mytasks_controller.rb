class MytasksController < ApplicationController
  before_action :authenticate_user!
  def index
    if params[:new]
      @mytasks = current_user.tasks.not_complete.order(updated_at: :desc).page(params[:page]).limit(6)
    elsif params[:old]
      @mytasks = current_user.tasks.not_complete.order(updated_at: :asc).page(params[:page]).limit(6)
    elsif params[:emergency]
      @mytasks = current_user.tasks.not_complete.order(deadline: :asc).page(params[:page]).limit(6)
    else
      @mytasks = current_user.tasks.not_complete.page(params[:page]).limit(6)
    end
  end
end
