class OrderBuilder < BaseService
  attr_accessor :order
  attr_accessor :errors

  def initialize
    @order_attributes ||= {}
    @booking_attributes ||= {}
    @client_attributes ||= {}
    @car_attributes ||= {}
    @errors = {}
  end

  def create
    ActiveRecord::Base.transaction do
      order = @workshop.orders.build(@order_attributes)
      order.client = get_client
      order.car = get_car
      order.build_booking(@booking_attributes)

      if order.save
        @order = order
      else
        report_errors(order)
        raise ActiveRecord::Rollback
      end
      @order
    end
  end

  ##
  # Set the order workshop
  # The workshop is to be authorized
  #
  def set_workshop(workshop)
    @workshop = workshop
  end

  def set_attributes(attrs = {})
    if attrs
      copy_attrs(@order_attributes, attrs, [:state])
    end
  end

  def set_booking_attributes(attrs = {})
    if attrs
      copy_attrs(@booking_attributes, attrs, [:start_date, :end_date, :color, :description])
    end
  end

  def set_client_attributes(attrs)
    if attrs and attrs.is_a? Hash
      copy_attrs(@client_attributes, attrs, [:name, :phone])
    elsif attrs
      @client_id = attrs
    end
  end

  def set_car_attributes(attrs)
    if attrs and attrs.is_a? Hash
      copy_attrs(@car_attributes, attrs, [:description, :license_id])
    elsif attrs
      @car_id = attrs
    end
  end

  private
  def get_client
    if @client_id
      @workshop.clients.find(@client_id)
    elsif @client_attributes
      @workshop.clients.build(@client_attributes)
    end
  rescue ActiveRecord::RecordNotFound => exception
    fail(:client, :id, I18n.t('activerecord.errors.models.client.not_found'))
  end

  def get_car
    if @car_id
      @workshop.cars.find(@car_id)
    elsif @car_attributes
      @workshop.cars.build(@car_attributes)
    end
  rescue ActiveRecord::RecordNotFound => exception
    fail(:car, :id, I18n.t('activerecord.errors.models.car.not_found'))
  end

  def copy_attrs(dest, source, attrs_list)
    attrs_list.each do |k|
      dest.merge!(k => source[k]) if source.has_key?(k)
    end
  end

  def report_errors(order)
    [:client, :car, :booking].each do |submodel|
      (order.errors.messages[submodel] || []).each do |message|
        fail(submodel, :id, message)
      end

      report_submodel_errors(submodel, order.send(submodel))
    end
  end

  def report_submodel_errors(key, model)
    if model
      model.errors.messages.each do |k, v|
        fail(key, k, v)
      end
    end
  end

  def fail(param, key, message)
    @errors[param] ||= {}
    @errors[param][key] ||= []
    @errors[param][key] << message
    nil
  end

  attr_accessor :order_attributes
  attr_accessor :booking_attributes
  attr_accessor :client_id
  attr_accessor :client_attributes
  attr_accessor :car_id
  attr_accessor :car_attributes
  attr_accessor :workshop
end