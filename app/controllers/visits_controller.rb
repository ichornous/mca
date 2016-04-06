class VisitsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_workshop
  before_action :convert_unixtime!, only: [:create, :update]
  before_action :set_policies
  before_action :authorize_user!

  # GET /events
  # GET /events.json
  def index
    if (params['start'] && params['end'])
      @visits = Visit.range(@workshop, params['start'].to_datetime, params['end'].to_datetime)
      if @workshop.nil? then
        @visits.each do |x|
          x.color = x.order.workshop.color
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
    @visit.build_order
    3.times do
      order_service = @visit.order.order_services.build
      order_service.service = Service.all().where(:name => 'MT').first
    end
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @visit = Visit.new(event_params)
    @visit.workshop = @workshop
    respond_to do |format|
      if @visit.save
        format.html { redirect_to @visit, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @visit }
      else
        format.html { render :new }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @visit.workshop = @workshop
    respond_to do |format|
      if @visit.update(event_params)
        format.html { redirect_to visits_url, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @visit }
      else
        format.html { render :edit }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
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
    def set_event
      @visit = Visit.find(params[:id])
    end

    def set_workshop
      @workshop_list = Workshop.all()
      if params[:workshop_id].nil?
        @workshop = current_user.workshop
      else
        @workshop = Workshop.find(params[:workshop_id])
      end
    end

    # Setup access policies
    def set_policies
      directory_policy = DirectoryAccessPolicy.new current_user
      @workshop_policy = WorkshopAccessPolicy.new(directory_policy, current_user)
      @event_policy = VisitAccessPolicy.new(@workshop_policy, current_user)
    end

    # Ensure that the user has enough permissions to execute the request
    def authorize_user!
      access = true
      if params[:action] == 'index'
        access &= @event_policy.index?(@workshop)
      elsif params[:action] == 'show'
        access &= @event_policy.show?(@visit)
      elsif params[:action] == 'create' or params[:action] == 'new'
        access &= @event_policy.create?(@workshop)
      elsif params[:action] == 'update' or params[:action] == 'edit'
        access &= @event_policy.update?(@visit)
        # if we move `event` from one `workshop` into another
        if @visit.workshop != @workshop
          access &= @workshop_policy.update?(@visit.workshop)
          access &= @workshop_policy.update?(@workshop)
        end
      elsif params[:action] == 'destroy'
        access &= @event_policy.delete?(@visit)
      else
        access = false
      end

      unless access
        respond_to do |format|
          format.html { redirect_to visits_path }
          format.json { render json: {}, status: :unauthorized }
        end
      end
    end

    # Ensure that range parameters are converted to DateTime
    def convert_unixtime!
      [:start, :end].each do |i|
        unless params[:visit][i].nil? or params[:visit][i].empty?
          params[:visit][i] = params[:visit][i].to_datetime
        else
          params[:visit][i] = nil
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:visit).permit(:title, :description, :date)
    end
end
