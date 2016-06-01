class OrdersController < ApplicationController
  DEFAULT_DATE_FORMAT = '%Y-%m-%d'

  before_action :set_order, only: [:show, :update, :destroy]
  before_action :set_workshop

  def index
    authorize Order

    cursor_date_value = parse_day(params[:day])
    @cursor_date = fmt_day(cursor_date_value)
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = @workshop.build_order
    authorize @order
  end

  # POST /events
  # POST /events.json
  def create
    order_builder = OrderBuilder.new
    order_builder.set_workshop(@workshop)
    order_builder.set_attributes(state: 'new')
    order_builder.set_booking_attributes(booking_params)
    order_builder.set_client_attributes(params[:client])
    order_builder.set_car_attributes(params[:car])

    @order = order_builder.create
    if @order
      redirect_to visits_url(day: fmt_day(booking.start_date)), notice: t('.success')
    else
      render :new
    end
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
    authorize @order = @workshop.orders.find(params[:id])
  end

  def set_workshop
    authorize @workshop = Workshop.find(params[:workshop_id])
  end

  def fmt_day(date)
    date.strftime(DEFAULT_DATE_FORMAT)
  end

  def parse_day(str)
    DateTime.strptime(str, DEFAULT_DATE_FORMAT) rescue DateTime.now
  end
end