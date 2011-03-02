class ExternalUpdatesController < ActionController::Base

  # Find the existing user in the database for the supplied id or create a new
  # one.
  #
  # @example Find the user.
  #   controller.user
  #
  # @return [ User ] The existing user or a new one.
  expose(:user) do
    user = User.where(email: decrypted["email"]).first
    if user
      user.tap { |u| u.write_attributes(decrypted) }
    else
      User.new(decrypted).tap do |u|
        u.account = Account.where(name: "HR New Media").first
        u.password = "hrn3wm3d1a"
        u.password_confirmation = "hrn3wm3d1a"
      end
    end
  end

  # Update an existing user or create a new one with the attributes supplied in
  # the encrypted JSON string.
  #
  # @example Update the user.
  #   post :update_user, user: { name: "Ted" }
  #
  # @return [ String ] The success or failure JSON.
  def update_user
    if user.save
      render json: { status: "success" }
    else
      render json: { status: "error", message: user.errors }
    end
  end

  private

  # Get the JSON string decrypted.
  #
  # @example Decrypt the JSON.
  #   controller.decrypted
  #
  # @return [ Hash ] The decrypted JSON string as a hash.
  def decrypted
    @decrypted ||=
      JSON.parse(Encryptor.decrypt(value: params[:user].encode("ISO-8859-1")))
  end
end
