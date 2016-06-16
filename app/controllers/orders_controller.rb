class OrdersController < ApplicationController
  DEFAULT_DATE_FORMAT = '%Y-%m-%d'

  before_action :set_workshop
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :set_date, only: [:index, :new]
  def index
    authorize Order

    @cursor_date = fmt_day(@cursor_date_value)
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @client = @order.client
    @car = @order.car
  end

  # GET /orders/new
  def new
    @order = @workshop.orders.build
    @order.start_date = @cursor_date_value
    @order.end_date = @cursor_date_value

    @client = @workshop.clients.build
    @car = @workshop.cars.build

    authorize @order
    authorize @car
    authorize @client
  end

  # POST /events
  # POST /events.json
  def create
    order_builder = OrderBuilder.new(@workshop)
    order_builder.order_attributes = unsafe_params[:order].except(:id)
    order_builder.client_attributes = unsafe_params[:client]
    order_builder.car_attributes = unsafe_params[:car]

    if order_builder.create
      redirect_to orders_url(day: fmt_day(order_builder.order.start_date)), notice: t('.success')
    else
      @order = order_builder.order
      @client = order_builder.client
      @car = order_builder.car

      @client_errors = order_builder.client.errors
      @car_errors = order_builder.car.errors
      @order_errors = order_builder.order.errors
      render :new
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    order_builder = OrderBuilder.new(@workshop)
    order_builder.order_attributes = unsafe_params[:order].merge(id: @order.id)
    order_builder.client_attributes = unsafe_params[:client]
    order_builder.car_attributes = unsafe_params[:car]

    if order_builder.create
      redirect_to orders_url(day: fmt_day(order_builder.order.start_date)), notice: t('.success')
    else
      @order = order_builder.order
      @client = order_builder.client
      @car = order_builder.car

      @client_errors = order_builder.client.errors
      @car_errors = order_builder.car.errors
      @order_errors = order_builder.order.errors
      render :show
    end
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
    authorize @order = @workshop.orders.find(params[:id])
  end

  def set_workshop
    authorize @workshop = current_user.current_workshop
  end

  def set_date
    @cursor_date_value = parse_day(params[:day]) || DateTime.now
  end

  def fmt_day(date)
    date.strftime(DEFAULT_DATE_FORMAT)
  end

  def parse_day(str)
    DateTime.strptime(str, DEFAULT_DATE_FORMAT) rescue nil
  end

  def unsafe_params
    @unsafe_params ||= ActiveSupport::HashWithIndifferentAccess.new(params)
    @unsafe_params
  end
end