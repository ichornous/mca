class CarBuilder
  def initialize(workshop)
    @workshop = workshop
  end

  def build(params)
    params = permit(params)
    if params[:id]
      car = @workshop.cars.find(params[:id])
    else
      car = @workshop.cars.build
    end

    car.assign_attributes(params.except(:id))
    car
  end

  private
  def permit(params)
    params.slice(:id, :description, :license_id)
  end
end