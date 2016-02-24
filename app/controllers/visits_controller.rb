class VisitsController < ApplicationController
  before_action :set_visit, only: [:show, :edit, :update, :destroy]
  before_action :set_workshop

  # GET /events
  # GET /events.json
  def index
    if (params['start'] && params['end'])
      @visits = Visit.range(@workshop, params['start'].to_datetime, params['end'].to_datetime)
      if @workshop.nil? then
        @visits.each do |x|
          x.color = x.order.workshop.color rescue 'rgb(0,0,255)'
        end
      end
      @visits
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
    @visit.build_order
    @visit.order.order_services.build
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @visit = Visit.new(event_params)
    if @visit.save
      redirect_to edit_visit_url(@visit), notice: 'Booking was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /events/1
  def update
    if @visit.update(event_params)
      redirect_to edit_visit_url(@visit), notice: 'Booking was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @visit.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_visit
      @visit = Visit.find(params[:id])
    end

    def set_workshop
      @workshop = current_user.current_workshop
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:visit).permit(:client_name,
                                    :car_name,
                                    :phone_number,
                                    :description,
                                    :start_date,
                                    :end_date,
                                    order_attributes: [:workshop_id,
                                                       order_services_attributes: [:_destroy,
                                                                                   :service_id,
                                                                                   :amount,
                                                                                   :cost,
                                                                                   :time]])
    end
end
