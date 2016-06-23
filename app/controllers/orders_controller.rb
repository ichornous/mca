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
    @order_form = OrderForm.new(@order)
  end

  # GET /orders/new
  def new
    @order_form = OrderForm.from_workshop(@workshop, date: @cursor_date_value)
    authorize @order_form
  end

  # POST /events
  # POST /events.json
  def create
    @order_form = OrderForm.from_workshop(@workshop)

    if @order_form.submit(params[:order].permit!)
      redirect_to orders_url(day: fmt_day(@order_form.start_date)), notice: t('.success')
    else
      render :new
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @order_form = OrderForm.new(@order)

    if @order_form.submit(params[:order].permit!)
      redirect_to orders_url(day: fmt_day(@order_form.start_date)), notice: t('.success')
    else
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
end