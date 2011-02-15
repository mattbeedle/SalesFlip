class TaskMailerJob
  @queue = :background

  def self.perform(task_id)
    TaskMailer.assignment_notification(Task.find(task_id)).deliver
  end
end
