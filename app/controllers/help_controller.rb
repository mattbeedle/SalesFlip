class HelpController < ApplicationController
  layout 'help'

  around_filter :set_locale
  skip_before_filter :authenticate_user!

  def set_locale
    I18n.with_locale(params[:locale]) do
      yield
    end
  end
end
