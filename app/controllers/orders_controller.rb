class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_workshop
  before_action :set_policies
  before_action :authorize_user!

  def index
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  def set_workshop
    @workshop_list = Workshop.all()
    if params[:workshop_id].nil?
      @workshop = current_user.workshop
    else
      @workshop = Workshop.find(params[:workshop_id])
    end
  end

  # Setup access policies
  def set_policies
    directory_policy = DirectoryAccessPolicy.new current_user
    @workshop_policy = WorkshopAccessPolicy.new(directory_policy, current_user)
    @order_policy = OrderAccessPolicy.new(@workshop_policy, current_user)
  end

  # Ensure that the user has enough permissions to execute the request
  def authorize_user!
    access = true
    if params[:action] == 'index'
      access &= @order_policy.index?(@workshop)
    elsif params[:action] == 'show'
      access &= @order_policy.show?(@model)
    elsif params[:action] == 'create' or params[:action] == 'new'
      access &= @order_policy.create?(@workshop)
    elsif params[:action] == 'update' or params[:action] == 'edit'
      access &= @order_policy.update?(@model)
      # if we move `event` from one `workshop` into another
      if @order.workshop != @workshop
        access &= @workshop_policy.update?(booking.workshop)
        access &= @workshop_policy.update?(@workshop)
      end
    elsif params[:action] == 'destroy'
      access &= @order_policy.delete?(booking)
    else
      access = false
    end

    unless access
      respond_to do |format|
        format.html { redirect_to events_path }
        format.json { render json: {}, status: :unauthorized }
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:orders).permit(:state)
  end
end