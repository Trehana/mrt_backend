require 'rails_helper'

RSpec.describe Graph, type: :model do
  # Runs before each test
  before(:each) do
    @graph = Graph.new
  end

  it 'Testing adding of the vertex' do
    @graph.add_vertex('A', 'B' => 7, 'C' => 8)
    expect('A' => { 'B' => 7, 'C' => 8 }).to eql(@graph.instance_variable_get(:@vertices))
  end

  it 'Testing of the shortest path' do
    @graph.add_vertex('A', 'B' => 7, 'C' => 8)
    @graph.add_vertex('B', 'A' => 7, 'F' => 2)
    @graph.add_vertex('C', 'A' => 8, 'F' => 6, 'G' => 4)
    @graph.add_vertex('D', 'F' => 8)
    @graph.add_vertex('E', 'H' => 1)
    @graph.add_vertex('F', 'B' => 2, 'C' => 6, 'D' => 8, 'G' => 9, 'H' => 3)
    @graph.add_vertex('G', 'C' => 4, 'F' => 9)
    @graph.add_vertex('H', 'E' => 1, 'F' => 3)

    expect(%w[H F B 12]).to eql @graph.shortest_path('A', 'H')
    expect(%w[D F 11]).to eql(@graph.shortest_path('H', 'D'))
  end
end
