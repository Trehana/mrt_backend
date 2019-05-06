module Api::V1
  class PathsController < ApiController
    swagger_controller :paths, 'Graph Management'

    swagger_api :index do
      summary 'Fetches the routes'
      notes 'This Fetches the best routes based on heuristics'
      param :query, :source, :string, :required, 'Source (Eg: NS1)'
      param :query, :destination, :string, :required, 'Destination (Eg: EW7)'
      param :query, :start_time, :string, :required, 'Start Time (Eg:"YYYY-MM-DDThh:mm" format, e.g. 2019-01-31T16:00)'
      param :query, :shortest_route_without_time, :boolean, :required, 'Shortest Route without time consideration(Least Line Transfers)'
      response :unauthorized
      response :not_acceptable, 'The request you made is not acceptable'
      response :requested_range_not_satisfiable
    end

    # GET /v1/
    def index
      @path = Path.new
      routes = @path.get_routes(params)
      if routes.present?
        render json: routes
      else
        render json: { message: "Route can't be found!" }
      end
    end
  end
end
