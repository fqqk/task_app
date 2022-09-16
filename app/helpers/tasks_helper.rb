module TasksHelper
  def button_text
    if action_name == 'new'
      '登録する'
    elsif action_name == 'edit'
      '更新する'
    end
  end

  def now_is_within_deadline?(deadline)
    deadline > Time.now
  end
end
