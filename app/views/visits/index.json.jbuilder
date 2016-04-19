json.array!(@visits) do |visit|
  json.extract! visit, :id, :car_name, :description, :color
  json.start visit.start_date.to_date.beginning_of_day
  json.end visit.end_date.end_of_day
  unless visit.order.nil? or visit.order.order_services.nil?
    json.services visit.order.order_services.map{|x| x.service.name}
  else
    json.services []
  end
  json.url visit_url(visit, format: :html)
end
