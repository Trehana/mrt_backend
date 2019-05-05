module Api::V1
  class GraphsController < ApiController
    swagger_controller :graphs, 'Graph Management'

    swagger_api :show do
      summary 'Fetches the routes'
      notes 'This Fetches the best routes'
      param :query, :source, :string, :required, 'Source'
      param :query, :destination, :string, :required, 'Destination'
      param :query, :start_time, :string, :required, 'Start Time'
      param :query, :shortest_route_without_time, :boolean, :required, 'Shortest Route without time consideration'
      response :unauthorized
      response :not_acceptable, 'The request you made is not acceptable'
      response :requested_range_not_satisfiable
    end

    # GET /v1/graphs
    def show
      @graph = Graph.new
      routes = @graph.get_routes(params)
      if routes.present?
        render json: routes
      else
        render json: { message: "Route can't be found!" }
      end
    end
  end
end
