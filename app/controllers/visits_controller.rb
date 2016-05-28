class VisitsController < ApplicationController
  DEFAULT_COLOR = 'rgb(0,0,255)'
  DEFAULT_DATE_FORMAT = '%Y-%m-%d'

  before_action :set_workshop
  before_action :set_visit, only: [:show, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    logger.warn("Attempt to query a non existent record: #{exception}")
    render nothing: true, status: 404
  end

#  rescue_from NoMethodError do |exception|
#    logger.warn("Attempt to send invalid query #{exception}")
#    render nothing: true, status: 400
#s  end

  # GET /events
  # GET /events.json
  #
  # Returns a list of events for a given date range
  # Params:
  #  +start+:: Beginning of the date range
  #  +end+:: End of the date range
  #  +day+:: Selected day
  def index
    authorize Visit

    cursor_date_value = parse_day(params[:day])
    @cursor_date = fmt_day(cursor_date_value)

    start_date = params[:start]
    end_date = params[:end]
    @visits = []
    if (start_date && end_date)
      @visits = Visit.range(@workshop, start_date.to_datetime, end_date.to_datetime)
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    authorize @visit
  end

  # GET /events/new
  #
  # Params:
  #  +at+: Fill `start_date`
  def new
    at = parse_day(params[:at])

    @visit = Visit.new
    @visit.start_date = at
    @visit.end_date = at.end_of_day
    @visit.workshop = @workshop
    @visit.build_order
    @visit.order.workshop = @workshop
    @visit.order.order_services.build

    authorize @visit
  end

  # POST /events
  def create
    @visit = Visit.new(event_params)
    authorize @visit

    if @visit.save
      redirect_to visits_url(day: fmt_day(@visit.start_date)), notice: t('.success')
    else
      render :new
    end
  end

  # PATCH/PUT /events/1
  def update
    authorize @visit

    if @visit.update(event_params)
      redirect_to visits_url(day: fmt_day(@visit.start_date)), notice: t('.success')
    else
      render :show
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    authorize @visit

    @visit.destroy
    redirect_to visits_url, notice: t('.success')
  end

  private
    def fmt_day(date)
      date.strftime(DEFAULT_DATE_FORMAT)
    end

    def parse_day(str)
      DateTime.strptime(str, DEFAULT_DATE_FORMAT) rescue DateTime.now
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_visit
      @visit = @workshop.visits.find(params[:id])
    end

    def set_workshop
      @workshop = current_user.current_workshop
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      delocalize_config = { start_date: :time, end_date: :time }
      params[:visit][:order_attributes] ||= {}
      filtered = params.require(:visit).permit(:client_name,
                                               :car_name,
                                               :phone_number,
                                               :description,
                                               :start_date,
                                               :end_date,
                                               :color,
                                               :workshop_id,
                                               order_attributes: [
                                                   :workshop_id,
                                                   order_services_attributes: [:_destroy,
                                                                               :id,
                                                                               :service_id,
                                                                               :amount,
                                                                               :cost,
                                                                               :time]]).delocalize(delocalize_config)

      unless (current_user.admin? or current_user.is_impersonated?) and filtered[:workshop_id] then
        filtered.merge!(workshop_id: @workshop.id)
      end
      filtered[:order_attributes].merge!(workshop_id: filtered[:workshop_id])
      filtered
    end
end
