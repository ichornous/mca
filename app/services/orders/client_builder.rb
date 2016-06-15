class ClientBuilder
  def initialize(workshop)
    @workshop = workshop
  end

  def build(params)
    params = permit(params)
    if params[:id]
      client = @workshop.clients.find(params[:id])
    else
      client = @workshop.clients.build
    end

    client.assign_attributes(params.except(:id))
    client
  end

  private
  def permit(params)
    params.slice(:id, :name, :phone)
  end
end