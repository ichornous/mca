module Api
  module V1
    class ClientsController < ApiController
      DEFAULT_PAGE_SIZE=10
      DEFAULT_PAGE=0

      respond_to :json

      before_action :set_workshop
      before_action :set_client, only: [:show, :update, :destroy]

      ##
      # == Params
      # limit (default is unlimited) Maximum number of search results
      # page (default is 0)
      # page_size (default is 10)
      # query Search query
      #
      def index
        page = params[:page]
        page_size = params[:page_size]
        limit = params[:limit]
        query = params[:query]

        @clients = @workshop.clients.all()
        @clients.where('lower(name) LIKE ?', "%#{query.downcase}%") if query
        @clients = @clients.limit(limit) if limit
        @clients = @clients.page(page || DEFAULT_PAGE).per(page_size || DEFAULT_PAGE_SIZE) if page or page_size

        respond_with(@clients)
      end

      def show
        respond_with(@client)
      end

      def create
        @client = Client.new(client_params)
        result = @client.save
        respond_with(@client, status: result ? :success : :unprocessable_entity)
      end

      def update
        result = @client.update(client_params)
        respond_with(@client, status: result ? :success : :unprocessable_entity)
      end

      def destroy
        @client.destroy
        respond_with(@client, status: :success)
      end

      private
      def client_params
        params.require(:client).permit(:name, :phone)
      end

      def set_workshop
        authorize @workshop = Workshop.find(params[:workshop_id])
      end

      def set_client
        authorize @client = @workshop.clients.find(params[:id])
      end
    end
  end
end
