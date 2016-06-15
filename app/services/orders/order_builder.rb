class OrderBuilder
  attr_reader :order
  attr_reader :client
  attr_reader :car

  attr_accessor :client_attributes
  attr_accessor :car_attributes
  attr_accessor :order_attributes

  def initialize(workshop)
    @workshop = workshop
    @order_attributes ||= {}
    @client_attributes ||= {}
    @car_attributes ||= {}
  end

  def create
    saved = false

    ActiveRecord::Base.transaction do
      @client = create_client
      @client.save

      @car = create_car
      @car.save

      @order = create_order
      @order.client = @client
      @order.car = @car
      saved = @order.save

      unless saved
        raise ActiveRecord::Rollback
      end
    end

    saved
  end

  def create_order
    params = permit(@order_attributes)

    if params[:id]
      order = @workshop.orders.find(params[:id])
    else
      order = @workshop.orders.build
    end

    params.delete(:id)
    order.assign_attributes(params)
    order
  end

  private
  attr_accessor :workshop

  def create_client
    ClientBuilder.new(@workshop).build(@client_attributes)
  end

  def create_car
    CarBuilder.new(@workshop).build(@car_attributes)
  end

  def permit(params)
    params.slice(:id, :start_date, :end_date, :description, :color, :state)
  end
end