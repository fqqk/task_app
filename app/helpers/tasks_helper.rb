module TasksHelper
  def button_text
    if action_name == "new"
      "登録する"
    elsif action_name == "edit"
      "更新する"
    end
  end

  def status_text(task_status)
    if task_status == "incomplete"
      "未対応"
    elsif task_status == "doing"
      "対応中"
    else
      "完了"
    end
  end

  def h_style(deadline)
    if deadline > DateTime.now
      "h-within-deadline"
    else
      "h-over-deadline"
    end
  end

  def border_style(deadline)
    if deadline > DateTime.now
      "border-within-deadline"
    else
      "border-over-deadline"
    end
  end

end
