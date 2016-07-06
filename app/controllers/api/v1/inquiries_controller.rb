module Api
  module V1
    class InquiriesController < ApiController
      respond_to :json

      before_action :set_workshop
      before_action :set_inquiry, only: [:show, :update, :destroy]

      # GET /api/v1/inquiries
      #
      # Returns a list of orders for a given date range
      # Params:
      #  +start+:: Beginning of the date range
      #  +end+:: End of the date range
      #  +page+:: Optional when used with pagination
      #  +page_max+:: Maximum number of items per page
      def index
        authorize Inquiry

        start_date = params[:start]
        end_date = params[:end]
        page = params[:page]
        page_max = params[:page_max]

        if (start_date.nil? or end_date.nil?) and not (current_user.admin? or current_user.manager?)
          render nothing: true, status: :not_acceptable
        else
          @inquiries = Inquiry.in_workshop(@workshop)
          @inquiries = @inquiries.in_range(start_date.to_datetime, end_date.to_datetime) if start_date and end_date
          @inquiries = @inquiries.page(page).per(limit) if page and page_max

          respond_with(@inquiries)
        end
      end

      # GET /api/v1/inquiries/1
      def show
        render json: @inquiry
      end

      ##
      # Creates a new inquiry and associates it with a booking details, a client and a car
      #
      # POST /api/v1/inquiries
      def create

      end

      # PATCH/PUT /inquiries/1
      def update

      end

      # DELETE /inquiries/1
      def destroy
        @inquiry.destroy

        render json: { id: @inquiry.id }, status: :ok
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_inquiry
        authorize @inquiry = @workshop.inquiries.find(params[:id])
      end

      def set_workshop
        authorize @workshop = Workshop.find(params[:workshop_id])
      end

      def unsafe_params
        @unsafe_params ||= ActiveSupport::HashWithIndifferentAccess.new(params)
        @unsafe_params
      end
    end
  end
end
