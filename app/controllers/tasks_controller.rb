class TasksController < InheritedResources::Base
  load_and_authorize_resource

  has_scope :assigned,              :type => :boolean
  has_scope :completed,             :type => :boolean
  has_scope :incomplete,            :type => :boolean
  has_scope :overdue,               :type => :boolean
  has_scope :due_today,             :type => :boolean
  has_scope :due_tomorrow,          :type => :boolean
  has_scope :due_this_week,         :type => :boolean
  has_scope :due_next_week,         :type => :boolean
  has_scope :due_later,             :type => :boolean
  has_scope :completed_today,       :type => :boolean
  has_scope :completed_yesterday,   :type => :boolean
  has_scope :completed_last_week,   :type => :boolean
  has_scope :completed_this_month,  :type => :boolean
  has_scope :completed_last_month,  :type => :boolean
  has_scope :for do |controller, scope, value|
    scope.for(User.get(value))
  end
  has_scope :assigned_by do |controller, scope, value|
    scope.assigned_by(User.get(value))
  end

  helper_method :tasks_index_cache_key

  def create
    create! do |success, failure|
      success.js { render :text => "true" }
      success.html { return_to_or_default tasks_path(:incomplete => true, :for => current_user.id) }
    end
  end

  def update
    update! do |success, failure|
      success.html do
        return_to_or_default tasks_path(:incomplete => true)
        if params[:task] and params[:task][:assignee_id]
          flash[:notice] = I18n.t(:task_reassigned, :user => @task.assignee.email)
        end
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { return_to_or_default tasks_path(:incomplete => true) }
    end
  end

protected
  def tasks_index_cache_key
    return @cache_key if defined?(@cache_key)

    tasks = Task.for(current_user)

    most_recent_task = tasks.all(:order => [:updated_at.desc]).first
    most_recent_task_with_asset = tasks.all(
      :asset_updated_at.not => nil,
      :order => [:asset_updated_at.desc]
    ).first

    @cache_key = Digest::SHA1.hexdigest([
      'tasks',
      most_recent_task.try(:updated_at).try(:to_i),
      most_recent_task_with_asset.try(:asset_updated_at).try(:to_i),
      tasks.count,
      params.flatten.join('-')
    ].join('-'))
  end

  def build_resource
    unless defined?(@task)
      attributes = { assignee_id: current_user.id }
      attributes.merge! params[:task] || {}

      @task = current_user.tasks.new(attributes)
    end

    @task.asset_id = params[:asset_id] if params[:asset_id]
    @task.asset_type = params[:asset_type] if params[:asset_type]
    @task
  end

  def collection
    unless fragment_exist?(tasks_index_cache_key)
      if params[:scopes]
        @tasks = {}
        scopes = %w(overdue due_today due_tomorrow due_this_week due_next_week due_later)

        scopes.each do |scope|
          scope = scope.to_sym
          @tasks[scope] = apply_scopes(Task).asc(:due_at).send(scope) if params[:scopes][scope]
        end
      else
        @overdue ||= apply_scopes(Task).overdue.asc(:due_at)
        @due_today ||= apply_scopes(Task).due_today.asc(:due_at)
        @due_tomorrow ||= apply_scopes(Task).due_tomorrow.asc(:due_at)
        @due_this_week ||= apply_scopes(Task).due_this_week.asc(:due_at)
        @due_next_week ||= apply_scopes(Task).due_next_week.asc(:due_at)
        @due_later ||= apply_scopes(Task).due_later.asc(:due_at)
      end
    end
  end
end
