module Api::V1
  class HomeController < ApiController
    def index_public
      render json: { message: 'Welcome to MRT API. Please contact admin to use our system.' }
    end
  end
end
