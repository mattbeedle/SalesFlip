module FormsHelper
  def datepicker_for(form, method, options = {})
    options = {:preset_date => true, :real_date => true}.merge(options)

    render :partial => 'shared/date_picker',
      :locals => { :form => form,
                   :method => method,
                   :options => options }
  end
end
