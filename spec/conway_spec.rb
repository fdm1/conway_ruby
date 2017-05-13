require 'spec_helper'

describe Conway::Grid do
  let(:sample_grid) { described_class.new([[1,1]]) }
  let(:single_row_grid) { described_class.new([[1,1], [1,2], [1,3]]) }
  let(:populated_grid) { described_class.new([[0,1], [1,1],
                                              [5,4], [5,5], [5,6],
                                              [9,10], [10,9],
                                              [10,10], [10,11],
                                              [11,10],
                                              [100,1]]) }

  it "has a set of points" do
    expect(sample_grid.points.length).to eq(1)
    expect(sample_grid.points).to include([1,1])
  end

  it "knows all the points it needs to check" do
    points = sample_grid.points_to_check
    expect(points.length).to eq(9)
  end

  it "can tell if a point is alive" do
    expect(sample_grid.point_is_alive?(1, 1)).to be true
    expect(sample_grid.point_is_alive?(1, 2)).to be false
  end

  it "can get all the neighbors for a point" do
    expect(sample_grid.neighbors(1,2).length).to eq(9)
    expect(sample_grid.neighbors(100,2).length).to eq(9)
  end

  it "can tell how many living neighbors a point has" do
    expect(populated_grid.point_living_neighbor_count(0,1)).to eq(1)
    expect(populated_grid.point_living_neighbor_count(1,1)).to eq(1)
    expect(populated_grid.point_living_neighbor_count(5,5)).to eq(2)
    expect(populated_grid.point_living_neighbor_count(100,1)).to eq(0)
  end

  it "starves a point with less than 2 neighbors" do
    expect(populated_grid.point_starves(12,9)).to be true
    expect(populated_grid.point_starves(100, 1)).to be true
    expect(populated_grid.point_starves(5, 5)).to be false
  end

  it "kills points with more than 3 points" do
    expect(populated_grid.point_is_overpopulated(10,10)).to be true
    expect(populated_grid.point_is_overpopulated(100, 1)).to be false
    expect(populated_grid.point_is_overpopulated(5, 5)).to be false
  end

  it "resurrects dead points with exactly 3 points" do
    expect(populated_grid.point_is_resurrected(11,11)).to be true
    expect(populated_grid.point_is_resurrected(-5, -5)).to be false
    expect(populated_grid.point_is_resurrected(10, 10)).to be false
  end

  it "decides which points live and die" do
    expect(populated_grid.point_should_live?(11,11)).to be true
    expect(populated_grid.point_should_live?(-5, -5)).to be false
    expect(populated_grid.point_should_live?(10, 10)).to be false

    expect(populated_grid.point_should_live?(10,10)).to be false
    expect(populated_grid.point_should_live?(100, 1)).to be false
    expect(populated_grid.point_should_live?(5, 5)).to be true
  end

  it "generates a new Grid with all points that should live" do
    evolved_grid = single_row_grid.evolve
    expect(evolved_grid.points.length).to eq(3)
    expect(evolved_grid.points).to include([0,2])
    expect(evolved_grid.points).to include([1,2])
    expect(evolved_grid.points).to include([2,2])
  end
end

describe Conway::Display do
  let (:small_grid) { Conway::Grid.new([[0,0],[1,1],[2,2]]) }
  let (:small_display) { described_class.new(small_grid) }

  it "knows the bounds of a grid" do
    expect(small_display.bottom_left).to eq([0,0])
    expect(small_display.top_right).to eq([2,2])
  end

  it "represents a Grid as a string" do
    rows = [Conway::DEAD_CELL*2 + Conway::LIVE_CELL,
            Conway::DEAD_CELL + Conway::LIVE_CELL + Conway::DEAD_CELL,
            Conway::LIVE_CELL + Conway::DEAD_CELL*2]
    expect(small_display.to_s).to eq(rows.join("\n"))
  end
end
