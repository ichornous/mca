module Api
  module V1
    class ClientsController < ApiController
      DEFAULT_PAGE_SIZE=10
      DEFAULT_PAGE=0

      respond_to :json

      before_action :set_workshop
      before_action :set_client, only: [:show, :update, :destroy]

      # Searches for registered clients in the database based on a given `query`
      #
      # == Parameters:
      # name::
      #   Name search pattern
      # phone::
      #   Phone number search pattern
      # limit::
      #   Maximum number of search results. Default is unlimited
      # page::
      #   When pagination is turned on, specifies the index of a results page. Default is `DEFAULT_PAGE`
      # page_size::
      #   Maximum number of search results on a single page. Default is `DEFAULT_PAGE_SIZE`
      def index
        page = params[:page]
        page_size = params[:page_size]
        limit = params[:limit]
        name = params[:name]
        phone = params[:phone]

        @clients = @workshop.clients.all()
        @clients = @clients.where('lower(name) LIKE ?', "%#{name.downcase}%") if name
        @clients = @clients.where('phone LIKE ?', "%#{phone}%") if phone
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
