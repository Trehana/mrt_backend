require 'priority_queue'
require 'csv'

class Graph
  @timeline = []
  @stations = []
  @timeline = []
  @descriptions = {}
  def initialize
    @vertices = {}
  end

  def create_timeline(time_period, isWeekday, isShortestPath)
    if isShortestPath == "true"
      @timeline =
          [['NS', 1, 10, 1000], ['EW', 1, 10, 1000], ['CG', 1, 10, 1000], ['NE', 1, 10, 1000],
          ['CC', 1, 10, 1000], ['CE', 1, 10, 1000], ['DT', 1, 10, 1000], ['TE', 1, 10, 1000]]
    else  
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
      if station_opening_date < start_date
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

  def get_available_station_graph
    station_list = []
    line_station_list = []
    station_index = 0
    line_station_index = 0
    single_line_station_index = 0
    junction_line_station_index = 0
    @stations.each do |line_stations|
      line_station_index = 0
      line_stations.each do |_line_station|
        adjacent_station = {}
        line_station_list = []
        if line_station_index.zero?
          adjacent_station.store(@stations[station_index][line_station_index + 1][0], @timeline[station_index][2])
        else
          adjacent_station[@stations[station_index][line_station_index - 1][0]] = @timeline[station_index][2]
          if line_station_index < (@stations[station_index].length - 1)
            adjacent_station.store(@stations[station_index][line_station_index + 1][0], @timeline[station_index][2])
          end
        end
        single_line_station_index = 0
        @stations.each do |junction_line_stations|
          unless single_line_station_index == station_index
            junction_line_station_index = 0
            junction_line_stations.each do |_single_line_station|
              if @stations[station_index][line_station_index][1] == @stations[single_line_station_index][junction_line_station_index][1]
                adjacent_station.store(@stations[single_line_station_index][junction_line_station_index][0], @timeline[single_line_station_index][3])
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
    station_list
  end

  def create_data(params)
    isWeekday = true
    time_period = ''
    start_date  = params[:start_time].to_date
    start_time  = params[:start_time].to_time.strftime('%H:%M')
    isShortestPath = params[:shortest_route_without_time]

    isWeekday = false if start_date.saturday? || start_date.sunday?
    if (start_time >= '06:00' && start_time <= '09:00') || (start_time >= '18:00' && start_time <= '21:00')
      time_period = 'peak'
    elsif (start_time >= '22:00' && start_time <= '23:59') || (start_time >= '00:00' && start_time <= '6:00')
      time_period = 'night'
    else
      time_period = 'offpeak'
    end
    create_timeline(time_period, isWeekday, isShortestPath)
    read_stations(start_date)
    get_available_station_graph
  end

  def add_vertex(name, edges)
    @vertices[name] = edges
  end

  def shortest_path(source, destination)
    return { message: 'Start Station Not Available' } unless @vertices.key?(source)
    return { message: 'Destination Station Not Available' } unless @vertices.key?(destination)

    maxint = (2**(0.size * 8 - 2) - 1)
    distances = {}
    previous = {}
    nodes = PriorityQueue.new

    @vertices.each do |vertex, _value|
      if vertex == source
        distances[vertex] = 0
        nodes[vertex] = 0
      else
        distances[vertex] = maxint
        nodes[vertex] = maxint
      end
      previous[vertex] = nil
    end

    while nodes
      smallest = nodes.delete_min_return_key

      if smallest == destination
        path = []
        while previous[smallest]
          path.push(smallest)
          smallest = previous[smallest]
        end
        total_travel_time = distances[destination]
        path << total_travel_time.to_s
        return path
      end

      break if smallest.nil? || (distances[smallest] == maxint)

      @vertices[smallest].each do |neighbor, _value|
        alt = distances[smallest] + @vertices[smallest][neighbor]
        next unless alt < distances[neighbor]

        distances[neighbor] = alt
        previous[neighbor] = smallest
        nodes[neighbor] = alt
      end
    end
    distances.inspect
  end

  def get_route_description(route)
    @descriptions = {}
    route.each do |station|
      @stations.each do |line_stations|
        # station_name = line_stations.each_index.select{|i| line_stations[i][0] == station}
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
      route_description << "Take #{key} line from #{value} to "
      unless description_index.zero?
        route_description[description_index-1] = route_description[description_index-1] + value
      end   
      description_index +=1
    end
    route_description
  end

  def get_path_description(path, params)
    message_body = {}
    travel_time = ''
    stations_travelled = 0
    travel_time = path.last + ' minutes' if params[:shortest_route_without_time] == 'false'
    route_path = path.delete(path.last)
    route = path.reverse.unshift(params[:source])
    stations_travelled = path.length if params[:shortest_route_without_time]
    route_description = get_route_description(route)
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
    graph_data.each do |data|
      add_vertex(data[0][0], data[0][1])
    end
    path_array = shortest_path(params[:source], params[:destination])
    get_path_description(path_array, params)
  end
end
