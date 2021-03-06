class UsersController < ApplicationController

  before_action :authenticate_user!

  def index
    @years = (1992..2018).to_a.reverse!

    if params[:search]
        @users = User.search(params[:search].downcase)
        @users += User.search(params[:search].capitalize)
        @users.uniq!
    else
        @users = User.all
    end
  end

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: params[:id])
  end

  def edit
    @user = current_user
    ['personal', 'social', 'contact', 'camp'].each do |key|
        @user.privacy_settings[key] ||= {}
    end
  end

  def update
    @user = User.find(params[:user_id])

    if @user.update_attributes(user_params)
      redirect_to user_profile_path(@user), notice: 'User updated.'
    else
      render :edit, alert: 'Unable to update user.'
    end
  end

  def update_privacy
    @user = User.find(params[:user_id])
    @user.privacy_settings = ['personal', 'social', 'contact', 'camp'].reduce({}) do |h, key|
      temp = params[:preferences][key] || {}
      temp.each do |k,v|
        temp[k] = (v == "true")
      end
      h[key] = temp; h
    end

    if @user.save
      redirect_to edit_user_profile_path(@user)
    else
      raise 'hello'
    end
  end

  def import
    uploaded_file = params[:file]
    importer = UserImporter.new(uploaded_file.path.to_s)
    if importer.valid_headers?
      importer.import_by_row
    else
      header_mismatch = importer.compare_headers
      flash[:error] = "Headers in spreadsheet do not match the expected layout. We expect: #{header_mismatch[:expected]}, and received #{header_mismatch[:actual]}"
      redirect_back(fallback_location: users_import_path)
    end
  end

  def upload
  end

  private

  def user_params
    params.require(:user).permit(
    :admin,
    :city,
    :country,
    :email,
    :facebook_username,
    :first_name,
    :instagram_username,
    :last_name,
    :linkedin_username,
    :maiden_name,
    :nickname,
    :password,
    :phone,
    :pinterest_name,
    :privacy_settings,
    :profile_photo_content_type,
    :profile_photo_file_name,
    :profile_photo_file_size,
    :profile_photo,
    :salutation,
    :state,
    :street_address,
    :tumblr_name,
    :twitter_handle,
    :zip_code,
    )
  end
end
