json.array!(@visits) do |visit|
  json.extract! visit, :id, :title, :description, :date, :color
  json.url visit_url(visit, format: :html)
end
