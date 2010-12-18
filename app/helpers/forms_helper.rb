module FormsHelper
  def datepicker_for(form, method)
    render(:partial => 'shared/date_picker', :locals => {:form => form, :method => method})
  end
end