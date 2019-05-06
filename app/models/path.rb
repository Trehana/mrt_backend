require 'priority_queue'
require 'csv'

class Path
  @timeline = []
  @stations = []
  @timeline = []
  @descriptions = {}
  @total_travel_time = 0
  def initialize
    @vertices = {}
  end

  # This method creates a timeline of the train lines based on the availablity of the stations and waiting times according to the start time entered.
  # ['NS', 1, 12, 1000] the first element represents line code. second element represents availablity(boolean).3rd and 4th elements represent NS 12 minutes waiting per station and 15minutes interchange time.
  # This details were formated according to the Bonus details given in the challenge. However to accomadate more train lines we could add this details to db with the above fields.
  def create_timeline(time_period, isWeekday, isShortestPath)
    if isShortestPath == 'true'
      # This timeline is based on the shortest path to destination station without time consideration hence, the time for the interchange is assumed a large amount so the algorhythm calculates the path with least number of interchanges.
      @timeline =
        [['NS', 1, 10, 1000], ['EW', 1, 10, 1000], ['CG', 1, 10, 1000], ['NE', 1, 10, 1000],
         ['CC', 1, 10, 1000], ['CE', 1, 10, 1000], ['DT', 1, 10, 1000], ['TE', 1, 10, 1000]]
    else
      # This timeline is based on the shortest path with time consideration.
      if time_period == 'peak' && isWeekday
        @timeline =
          [['NS', 1, 12, 15], ['EW', 1, 10, 15], ['CG', 1, 10, 15], ['NE', 1, 12, 15],
           ['CC', 1, 10, 15], ['CE', 1, 10, 15], ['DT', 1, 10, 15], ['TE', 1, 10, 15]]

      elsif time_period == 'night'
        @timeline =
          [['NS', 1, 10, 10], ['EW', 1, 10, 10], ['CG', 0, 0, 0], ['NE', 1, 10, 10],
           ['CC', 1, 10, 10], ['CE', 0, 0, 0], ['DT', 0, 0, 0], ['TE', 1, 8, 10]]

      else
        @timeline =
          [['NS', 1, 10, 10], ['EW', 1, 10, 10], ['CG', 1, 10, 10], ['NE', 1, 10, 10],
           ['CC', 1, 10, 10], ['CE', 1, 10, 10], ['DT', 1, 8, 10], ['TE', 1, 8, 10]]

      end
    end
  end

  # This method reads the csv data from the StationMap.csv given and adds the data into @stations array.
  def read_stations(start_date)
    rows = []
    CSV.foreach(Rails.root.join('public/uploads/StationMap.csv')) do |row|
      rows << row
    end
    ns = []
    ew = []
    cg = []
    ne = []
    cc = []
    ce = []
    dt = []
    te = []
    rows.delete_at(0)
    rows.each do |row|
      station_opening_date = Date.parse(row[2], '%Y/%m/%d')
      station_code = row[0][0, 2]
      if station_opening_date < start_date # Based on the start date stations already opened will be added to the stations array.
        if station_code == 'NS' && @timeline[0][1]
          ns << row
        elsif station_code == 'EW' && @timeline[1][1]
          ew << row
        elsif station_code == 'CG' && @timeline[2][1]
          cg << row
        elsif station_code == 'NE' && @timeline[3][1]
          ne << row
        elsif station_code == 'CC' && @timeline[4][1]
          cc << row
        elsif station_code == 'CE' && @timeline[5][1]
          ce << row
        elsif station_code == 'DT' && @timeline[6][1]
          dt << row
        elsif station_code == 'TE' && @timeline[7][1]
          te << row
        end
      end
    end
    @stations = [ns, ew, cg, ne, cc, ce, dt, te].compact.reject(&:empty?)
  end

  # This method generates a  weighted graph for the shortest path algorhythm based on the interchanges and the timeline.
  def get_available_station_graph
    station_list = []
    line_station_list = []
    station_index = 0
    line_station_index = 0
    single_line_station_index = 0
    junction_line_station_index = 0
    # Getting the adjacent staions of each available stations
    @stations.each do |line_stations|
      line_station_index = 0
      line_stations.each do |_line_station|
        adjacent_station = {}
        line_station_list = []
        if line_station_index.zero?
          adjacent_station.store(@stations[station_index][line_station_index + 1][0], @timeline[station_index][2])
        else
          adjacent_station[@stations[station_index][line_station_index - 1][0]] = @timeline[station_index][2] # assigning the time values for waiting
          if line_station_index < (@stations[station_index].length - 1)
            adjacent_station.store(@stations[station_index][line_station_index + 1][0], @timeline[station_index][2])
          end
        end
        single_line_station_index = 0
        # Getting the adjacent interchange staions of each available stations
        @stations.each do |junction_line_stations|
          unless single_line_station_index == station_index
            junction_line_station_index = 0
            junction_line_stations.each do |_single_line_station|
              if @stations[station_index][line_station_index][1] == @stations[single_line_station_index][junction_line_station_index][1]
                adjacent_station.store(@stations[single_line_station_index][junction_line_station_index][0], @timeline[single_line_station_index][3]) # assigning the time values for interchange
              end
              junction_line_station_index += 1
            end
          end
          single_line_station_index += 1
        end
        line_station_list.push([@stations[station_index][line_station_index][0], adjacent_station])
        station_list.push(line_station_list)
        line_station_index += 1
      end
      station_index += 1
    end
    station_list # The station list for the graph. formatted as [[["NS1", {"NS2"=>12, "EW24"=>15}]]]
  end

  def create_data(params)
    isWeekday = true
    time_period = ''
    # Validation of the start time entered.
    begin
      start_date = params[:start_time].to_date
    rescue ArgumentError
      return { message: 'Invalid Start Time' }
    end

    start_time = params[:start_time].to_time.strftime('%H:%M')
    isShortestPath = params[:shortest_route_without_time]

    # Determining the start time belonging time period.
    isWeekday = false if start_date.saturday? || start_date.sunday? # Checking if the start day is a weekday
    if (start_time >= '06:00' && start_time <= '09:00') || (start_time >= '18:00' && start_time <= '21:00') # Checking if the start time is peak
      time_period = 'peak'
    elsif (start_time >= '22:00' && start_time <= '23:59') || (start_time >= '00:00' && start_time <= '6:00') # Checking if the start time is night
      time_period = 'night'
    else
      time_period = 'offpeak'
    end
    ##########
    # Creating timeline of the train lines.
    create_timeline(time_period, isWeekday, isShortestPath)
    # Reading the stations from the csv.
    read_stations(start_date)
    # Generating the available station graph.
    get_available_station_graph
  end

  # This method adds veritices to graph
  def add_vertex(name, edges)
    @vertices[name] = edges
  end

  def shortest_path(source, destination)
    return { message: 'Start Station Not Available' } unless @vertices.key?(source)
    return { message: 'Destination Station Not Available' } unless @vertices.key?(destination)

    maxint = (2**(0.size * 8 - 2) - 1)
    distances = {} # Distance from start to node
    previous = {} #  Previous node in optimal path from source
    nodes = PriorityQueue.new # Priority queue of all nodes in Graph

    @vertices.each do |vertex, _value|
      if vertex == source # Set root node as distance of 0
        distances[vertex] = 0
        nodes[vertex] = 0
      else
        distances[vertex] = maxint
        nodes[vertex] = maxint
      end
      previous[vertex] = nil
    end

    while nodes
      smallest = nodes.delete_min_return_key # Vertex in nodes with smallest distance in distances

      if smallest == destination # If the closest node is our target we're done so print the path
        path = []
        while previous[smallest] # Traverse through nodes til we reach the root which is 0
          path.push(smallest)
          smallest = previous[smallest]
        end
        @total_travel_time = distances[destination]
        return path
      end

      break if smallest.nil? || (distances[smallest] == maxint) # All remaining vertices are inaccessible from source

      @vertices[smallest].each do |neighbor, _value| # Look at all the nodes that this vertex is attached to
        alt = distances[smallest] + @vertices[smallest][neighbor] # Alternative path distance
        next unless alt < distances[neighbor] # If there is a new shortest path update our priority queue

        distances[neighbor] = alt
        previous[neighbor] = smallest
        nodes[neighbor] = alt
      end
    end
    distances.inspect
  end

  # This method formats the route description according to the needed output.
  def get_route_description(route, params)
    @descriptions = {} # Hash to store station code along with station names.
    route.each do |station|
      @stations.each do |line_stations|
        line_stations.each do |line_station|
          if line_station[0] == station
            station_name = line_station[1]
            @descriptions.store(station, station_name)
          end
        end
      end
    end
    route_description = []
    description_index = 0
    @descriptions.each do |key, value|
      route_description << "Take #{key[0, 2]} line from #{value} to " unless key == params[:destination]
      unless description_index.zero?
        if route_description[description_index - 1].include? value 
          if key[0, 2] == params[:destination][0, 2] # Checks whether the destination station is a interchange station 
            route_description[description_index - 1] = ''
            @timeline.each do |train_line|
              if train_line[0] == params[:destination][0, 2]
                @total_travel_time = (@total_travel_time - train_line[3])
              end
            end
          else
            route_description[description_index - 1] = "Change from #{@descriptions.keys[description_index - 1][0, 2]} to #{key[0, 2]} line"
          end
        else
          route_description[description_index - 1] = route_description[description_index - 1] + value
        end
      end
      description_index += 1
    end
    route_description.reject(&:empty?)
  end

  def get_path_description(path, params)
    message_body = {}
    travel_time = ''
    stations_travelled = 0
    route = path.reverse.unshift(params[:source])
    stations_travelled = path.length if params[:shortest_route_without_time]
    route_description = get_route_description(route, params)
    travel_time = @total_travel_time.to_s + ' minutes' if params[:shortest_route_without_time] == 'false'
    travel_summery = 'Travel from ' + @descriptions[params[:source]] + ' to ' + @descriptions[params[:destination]]
    message_body.store('Travel Summery', travel_summery)
    message_body.store('Time', travel_time) unless travel_time == ''
    message_body.store('Stations Travelled', stations_travelled) unless stations_travelled.zero?
    message_body.store('Route', route)
    message_body.store('Route Description', route_description)
    message_body
  end

  def get_routes(params)
    graph_data = create_data(params)
    if graph_data.is_a?(Array)
      graph_data.each do |data|
        add_vertex(data[0][0], data[0][1])
      end
      path_array = shortest_path(params[:source], params[:destination])
      if path_array.is_a?(Array)
        get_path_description(path_array, params)
      else
        path_array
      end
    else
      graph_data
    end
  end
end
