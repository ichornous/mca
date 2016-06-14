json.array!(@orders) do |order|
  json.extract! order, :id, :description, :color
  json.start order.start_date.to_date.beginning_of_day
  json.end order.end_date.end_of_day
  json.client_name order.client.name
  json.car_name order.car.description
  unless order.order_services.nil?
    json.services order.order_services.map{|x| x.service.name}
  else
    json.services []
  end
  json.url workshop_order_url(@workshop.id, order, format: :html)
end
