module Api
  module V1
    class OrdersController < ApiController
      respond_to :json

      before_action :set_workshop
      before_action :set_order, only: [:show, :update, :destroy]

      class AuthenticationError < StandardError; end

      rescue_from ActiveRecord::RecordNotFound do |exception|
        logger.warn("Attempt to query a non existent record: #{exception}")
        render nothing: true, status: :not_found
      end

      # GET /api/v1/orders
      #
      # Returns a list of orders for a given date range
      # Params:
      #  +start+:: Beginning of the date range
      #  +end+:: End of the date range
      def index
        authorize Order

        start_date = params[:start]
        end_date = params[:end]

        @orders = Order.in_workshop(@workshop)
        @orders = @orders.in_range(start_date.to_datetime, end_date.to_datetime) if start_date and end_date

        render json: @orders
      end

      # GET /api/v1/orders/1
      def show
        render json: @order
      end

      ##
      # Creates a new order and associates it with a booking details, a client and a car
      #
      # POST /api/v1/orders
      #
      # = Examples
      #
      # ==Create a new order along with booking details, a client and a car
      # {
      #   booking: {
      #     start_date: '05-06-2016'
      #     end_date: '20-06-2016'
      #     color: '#ff0000'
      #     description: 'Lorem impsum'
      #   },
      #   client: {
      #     name: 'John Doe',
      #     phone_number: ['+.....']
      #   },
      #   car: {
      #     description: 'Citroen C4 (2012)'
      #   }
      # }
      #
      # ==Create a new order for a returning client and a new car
      # {
      #   booking: {
      #     start_date: '05-06-2016'
      #     end_date: '20-06-2016'
      #     color: '#ff0000'
      #     description: 'Lorem impsum'
      #   },
      #   client: 223,
      #   car: {
      #     description: 'Mercedes C-Klass (2016)'
      #   }
      # }
      #
      def create
        order_builder = OrderBuilder.new
        order_builder.set_workshop(@workshop)
        order_builder.set_attributes(state: 'new')
        order_builder.set_booking_attributes(booking_params)
        order_builder.set_client_attributes(params[:client])
        order_builder.set_car_attributes(params[:car])

        if order_builder.create
          render json: { id: order_builder.order.id }, status: :ok
        else
          report_error(order_builder.errors)
        end
      end

      # PATCH/PUT /orders/1
      def update
        if @order.update(order_params)
          render json: { id: @order.id }, status: :ok
        else
          render json: @errors, status: :unprocessable_entity
        end
      end

      # DELETE /orders/1
      def destroy
        @order.destroy

        render json: { id: @order.id }, status: :ok
      end

      private
      def report_error(error_hash = {})
        render json: { errors: error_hash }, status: :unprocessable_entity
      end

      def booking_params
        return nil unless params[:booking]

        params[:booking].delocalize({ start_date: :time, end_date: :time })
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_order
        authorize @order = @workshop.orders.find(params[:id])
      end

      def set_workshop
        authorize @workshop = Workshop.find(params[:workshop_id])
      end

      def order_params
        permitted = params.permit(services: [:service_id, :amount, :cost, :time])
        permitted[:order_service_attributes] = permitted.delete :services
        permitted.permit!
      end
    end
  end
end
