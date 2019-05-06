require 'rails_helper'

RSpec.describe Path, type: :model do
  # Runs before each test
  before(:each) do
    @path = Path.new
  end

  it 'Testing of get routes method without time consideration' do
    params = { :source => 'EW27',
               :destination => 'DT12',
               :start_time => '2019-05-10T07:00',
               :shortest_route_without_time => 'true' }

    expected_result = { 'Travel Summery' => 'Travel from Boon Lay to Little India', 'Stations Travelled' => 18, 'Route' => %w[EW27 EW26 EW25 EW24 EW23 EW22 EW21 EW20 EW19 EW18 EW17 EW16 EW15 EW14 EW13 EW12 DT14 DT13 DT12], 'Route Description' => ['Take EW line from Boon Lay to Lakeside', 'Take EW line from Lakeside to Chinese Garden', 'Take EW line from Chinese Garden to Jurong East', 'Take EW line from Jurong East to Clementi', 'Take EW line from Clementi to Dover', 'Take EW line from Dover to Buona Vista', 'Take EW line from Buona Vista to Commonwealth', 'Take EW line from Commonwealth to Queenstown', 'Take EW line from Queenstown to Redhill', 'Take EW line from Redhill to Tiong Bahru', 'Take EW line from Tiong Bahru to Outram Park', 'Take EW line from Outram Park to Tanjong Pagar', 'Take EW line from Tanjong Pagar to Raffles Place', 'Take EW line from Raffles Place to City Hall', 'Take EW line from City Hall to Bugis', 'Take DT line from Bugis to Rochor', 'Take DT line from Rochor to Little India'] }
    expect(expected_result).to eql(@path.get_routes(params))
  end
  it 'Testing of get routes method with time consideration' do
    params = { :source => 'EW27',
               :destination => 'DT12',
               :start_time => '2019-05-10T07:00',
               :shortest_route_without_time => 'false' }

    expected_result = {"Travel Summery"=>"Travel from Boon Lay to Little India", "Time"=>"135 minutes", "Stations Travelled"=>14, "Route"=>["EW27", "EW26", "EW25", "EW24", "EW23", "EW22", "EW21", "CC22", "CC21", "CC20", "CC19", "DT9", "DT10", "DT11", "DT12"], "Route Description"=>["Take EW line from Boon Lay to Lakeside", "Take EW line from Lakeside to Chinese Garden", "Take EW line from Chinese Garden to Jurong East", "Take EW line from Jurong East to Clementi", "Take EW line from Clementi to Dover", "Take EW line from Dover to Buona Vista", "Change from EW to CC line", "Take CC line from Buona Vista to Holland Village", "Take CC line from Holland Village to Farrer Road", "Take CC line from Farrer Road to Botanic Gardens", "Take DT line from Botanic Gardens to Stevens", "Take DT line from Stevens to Newton", "Take DT line from Newton to Little India"]}
    expect(expected_result).to eql(@path.get_routes(params))
  end

  it 'Testing adding of the vertex' do
    @path.add_vertex('A', 'B' => 7, 'C' => 8)
    expect('A' => { 'B' => 7, 'C' => 8 }).to eql(@path.instance_variable_get(:@vertices))
  end

  it 'Testing of the shortest path' do
    @path.add_vertex('A', 'B' => 7, 'C' => 8)
    @path.add_vertex('B', 'A' => 7, 'F' => 2)
    @path.add_vertex('C', 'A' => 8, 'F' => 6, 'G' => 4)
    @path.add_vertex('D', 'F' => 8)
    @path.add_vertex('E', 'H' => 1)
    @path.add_vertex('F', 'B' => 2, 'C' => 6, 'D' => 8, 'G' => 9, 'H' => 3)
    @path.add_vertex('G', 'C' => 4, 'F' => 9)
    @path.add_vertex('H', 'E' => 1, 'F' => 3)

    expect(%w[H F B]).to eql @path.shortest_path('A', 'H')
    expect(%w[D F]).to eql(@path.shortest_path('H', 'D'))
  end
end
