class OrderForm
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Order')
  end

  def initialize(order)
    @order = order

    @client_id = order.client.id
    @client_name = order.client.name
    @client_phone = order.client.phone

    @client_is_new = @client_id ? false : true

    @car_id = order.car.id
    @car_description = order.car.description
  end

  delegate :start_date, :end_date, :description, :color, to: :order

  attr_accessor :client_id
  attr_accessor :client_name
  attr_accessor :client_phone
  attr_accessor :client_is_new

  attr_accessor :car_id
  attr_accessor :car_description

  validates_presence_of :start_date, :end_date

  # Apply changes
  #
  # @param [Hash] params Form parameters
  def submit(params)

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

  #
  # Validation
  #
end
