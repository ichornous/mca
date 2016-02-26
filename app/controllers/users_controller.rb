class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_workshop
  before_action :set_policies
  before_action :set_assignable_roles, only: [:new, :edit, :create, :update]
  before_action :authorize_user!, only: [:index, :show, :edit, :update, :destroy]

  # Show users for a given workshop
  # +workshop_id+:: If a workshop identifier is not given, all users are returned
  # GET /users
  # GET /users.json
  def index
    if current_user.admin?
      index_admin
    else
      index_public
    end
  end

  def index_admin
    if @workshop.nil?
      @users = User.all()
    else
      @users = @workshop.users
    end
  end

  def index_public
    @users = @workshop.users
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.workshop = @workshop

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    user_params.delete(:username)
    @user.workshop = @workshop

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def set_workshop
      @workshop_list = Workshop.all()
      if params[:workshop_id].nil? and current_user.admin?
        @workshop = nil
      elsif params[:workshop_id].nil?
        @workshop = current_user.workshop
      else
        @workshop = Workshop.find(params[:workshop_id])
      end
    end

    # Setup access policies
    def set_policies
      directory_policy = DirectoryAccessPolicy.new current_user
      @workshop_policy = WorkshopAccessPolicy.new(directory_policy, current_user)
      @user_policy = UserAccessPolicy.new(@workshop_policy, current_user)
    end

    def set_assignable_roles
      @roles = User.roles.to_a.select{|w| @user_policy.assign_role?(w[0])}.map{ |w| [w[0].humanize, w[0]] }
    end

    # Ensure that the current user has access enough permissions to access a resource
    def authorize_user!
      access = true
      if params[:action] == 'index'
        access &= @user_policy.index?(@workshop)
      elsif params[:action] == 'show'
        access &= @user_policy.show?(@user)
      elsif params[:action] == 'new' or params[:action] == 'create'
        access &= @user_policy.create?(@workshop)
      elsif params[:action] == 'update' or params[:action] == 'edit'
        access &= @user_policy.update?(@user)
        # if we move `user` from one `workshop` into another
        if @user.workshop != @workshop
          access &= @workshop_policy.update?(@workshop)
          access &= @workshop_policy.update?(@user.workshop)
        end
      elsif params[:action] == 'destroy'
        access &= @user_policy.delete?(@user)
      else
        access = false
      end

      unless access
        respond_to do |format|
          format.html { redirect_to user_path(current_user) }
          format.json { render json: {}, status: :unauthorized }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user].permit(:username, :first_name, :last_name, :role, :email, :workshop_id)
    end
end
