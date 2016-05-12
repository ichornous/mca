class VisitsController < ApplicationController
  DEFAULT_COLOR = 'rgb(0,0,255)'
  before_action :set_visit, only: [:show, :update, :destroy]
  before_action :set_workshop

  # GET /events
  # GET /events.json
  def index
    @cursor_date = DateTime.strptime(params[:day], '%Y-%m-%d') rescue DateTime.now
    start_date = params['start']
    end_date = params['end']
    if (start_date && end_date)
      @visits = Visit.range(@workshop, start_date.to_datetime, end_date.to_datetime)
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @visit = Visit.new
    @visit.start_date = DateTime.now
    @visit.end_date = DateTime.now
    @visit.workshop = @workshop
    @visit.build_order
    @visit.order.workshop = @workshop
    @visit.order.order_services.build
  end

  # POST /events
  def create
    @visit = Visit.new(event_params)
    if @visit.save
      redirect_to visits_url(day: fmt_day(@visit.start_date)), notice: t('.success')
    else
      render :new
    end
  end

  # PATCH/PUT /events/1
  def update
    if @visit.update(event_params)
      redirect_to visits_url(day: fmt_day(@visit.start_date)), notice: t('.success')
    else
      render :show
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @visit.destroy
    redirect_to visits_url, notice: t('.success')
  end

  private
    def fmt_day(date)
      date.strftime('%Y-%m-%d')
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_visit
      @visit = Visit.find(params[:id])
    end

    def set_workshop
      @workshop = current_user.current_workshop
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      delocalize_config = { start_date: :time, end_date: :time }
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
                                                                               :service_id,
                                                                               :amount,
                                                                               :cost,
                                                                               :time]]).delocalize(delocalize_config)
      # Only non-impersonated administrators can override `workshop_id`
      unless current_user.admin? or current_user.is_impersonated? then
        filtered.merge!(workshop_id: @workshop.id)
        filtered[:order_attributes].merge!(workshop_id: @workshop.id)
      end
      filtered
    end
end
