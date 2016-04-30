class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_workshop

  before_action :set_assignable_roles, only: [:new, :edit, :create, :update]
  before_action :authorize_user

  # Show users for a given workshop
  # GET /users
  # GET /users.json
  def index
    if current_user.admin? and not current_user.is_impersonated?
      @users = User.all()
    else
      @users = @workshop.users
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    if current_user.admin? and not current_user.is_impersonated?
      @workshop_list = Workshop.all()
    end
  end

  # GET /users/1/edit
  def edit
    if current_user.admin? and not current_user.is_impersonated?
      @workshop_list = Workshop.all()
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    unless current_user.admin? or current_user.is_impersonated?
      user_params.delete(:workshop_id)
      @user.workshop = @workshop
    end

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    user_params.delete(:username)
    unless current_user.admin? or current_user.is_impersonated?
      user_params.delete(:workshop_id)
    end

    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def set_workshop
      @workshop = current_user.current_workshop
    end

    def set_assignable_roles
      @roles = User.roles.to_a.
          select{ |w| current_user.can_assign_role?(w[0]) }.
          map{ |w| [w[0].humanize, w[0]] }
    end

    # Ensure that the current user has access enough permissions to access a resource
    # Allow user to review and update his own profile
    # Only managers and admins are permitted to perform other actions
    def authorize_user
      return if is_owner?(@user) and not is_destroy?

      unless current_user.admin? or current_user.manager?
        redirect_to user_path(current_user)
      end
    end

    def is_destroy?
      params[:action] == 'destroy'
    end

    def is_owner?(user)
      not(user.nil?) and (user.id == current_user.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user].permit(:username, :first_name, :last_name, :role, :email, :locale, :workshop_id)
    end
end
