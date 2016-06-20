json.array!(@clients) do |client|
  json.extract! client, :id, :name, :phone
  json.url api_v1_workshop_clients_path(client, format: :json)

  json.workshop_id client.workshop.id
end