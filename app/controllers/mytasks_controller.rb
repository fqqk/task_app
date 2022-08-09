class MytasksController < ApplicationController
  before_action :authenticate_user!
  def index
    @mytasks = current_user.tasks
  end
end
