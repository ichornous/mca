module Api
  module V1
    class OrdersController < ApiController
      respond_to :json

      before_action :set_workshop
      before_action :set_order, only: [:show, :update, :destroy]


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
      #  +page+:: Optional when used with pagination
      #  +page_max+:: Maximum number of items per page
      def index
        authorize Order

        start_date = params[:start]
        end_date = params[:end]
        page = params[:page]
        page_max = params[:page_max]

        if (start_date.nil? or end_date.nil?) and not (current_user.admin? or current_user.manager?)
          render nothing: true, status: :not_acceptable
        else
          @orders = Order.in_workshop(@workshop)
          @orders = @orders.in_range(start_date.to_datetime, end_date.to_datetime) if start_date and end_date
          @orders = @orders.page(page).per(limit) if page and page_max

          respond_with(@orders)
        end
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
      #
      #   start_date: '05-06-2016'
      #   end_date: '20-06-2016'
      #   color: '#ff0000'
      #   description: 'Lorem impsum',
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
      #   start_date: '05-06-2016'
      #   end_date: '20-06-2016'
      #   color: '#ff0000'
      #   description: 'Lorem impsum',
      #   client: 223,
      #   car: {
      #     description: 'Mercedes C-Klass (2016)'
      #   }
      # }
      #
      def create
        order_builder = OrderBuilder.new(@workshop)
        order_builder.order_attributes = unsafe_params[:order].except(:id)
        order_builder.client_attributes = unsafe_params[:client]
        order_builder.car_attributes = unsafe_params[:car]

        if order_builder.create
          render json: { id: order_builder.order.id }, status: :ok
        else
          errors = {}
          [:order, :client, :car].each do |key|
            next unless order_builder.send(key).try(:errors).try(:any?)
            errors.merge!(key => order_builder.send(key).send(:errors))
          end

          render json: { errors: errors }, status: :unprocessable_entity
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

      end

      # Use callbacks to share common setup or constraints between actions.
      def set_order
        authorize @order = @workshop.orders.find(params[:id])
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
