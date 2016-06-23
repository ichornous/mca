class OrderForm
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Order')
  end

  def self.from_workshop(workshop, opts = {})
    order = workshop.orders.build
    order.start_date = opts[:date] if opts[:date]
    order.end_date = opts[:date] if opts[:date]
    order.client = workshop.clients.build
    order.car = workshop.cars.build

    OrderForm.new(order)
  end

  def initialize(order)
    @order = order
  end

  #
  # Accessors
  #
  delegate :start_date, :end_date, :description, :color, :workshop_id, to: :order
  delegate :id, :name, :phone, to: :client, prefix: true
  delegate :id, :description, :license_id, to: :car, prefix: true

  def order
    @order
  end

  def client
    @order.client
  end

  def car
    @order.car
  end

  # Apply changes
  #
  # @param [Hash] params Form parameters
  def submit(params)
    params.delocalize(start_date: :time, end_date: :time)
    ActiveRecord::Base.transaction do
      @client_is_new = params[:client_is_new]
      @car_is_new = params[:car_is_new]

      @order.attributes = params.slice(:start_date, :end_date, :description, :color)
      @order.client = find_or_create(:client, params[:client_id], params.slice(:name, :phone))
      @order.car = find_or_create(:car, params[:car_id], params.slice(:description, :license_id))

      if @order.valid? and @order.client.valid? and @order.car.valid?
        @order.client.save!
        @order.car.save!
        @order.save!
        true
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  #
  # Security
  #

  # Returns a reference to the associated workshop
  #
  # = Usage
  # This method should be used in the corresponding policy to determine
  # whether the user is authorized to access an object
  def workshop
    @order.workshop
  end

  private
  # Searches for the record in the database if +id+ is provided
  # Otherwise builds a new instance of the +model_kind+ with given +attributes+
  #
  # @param [Symbol] model_kind Symbolic model name (e.g. :client, :car)
  # @param [String] id Id of a record or a blank string
  # @param [Hash] attributes Model attributes
  def find_or_create(model_kind, id, attributes)
    factory = workshop.send(model_kind.to_s.pluralize(2).to_sym)
    unless id.blank?
      model = factory.find(id)
    else
      model = factory.build
      model.attributes = attributes
    end

    model
  end

  #
  # Validation
  #
end
