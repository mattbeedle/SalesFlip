class HelpController < ApplicationController
  layout 'help'

  around_filter :set_locale

  def set_locale
    I18n.with_locale(params[:locale]) do
      yield
    end
  end
end
