require "set"

module Conway

  DEAD_CELL = "."
  LIVE_CELL = "*"

  def self.run
    rand_points = []

    10000.times do |i|
      rand_points.push [rand(80), rand(80)]
    end
    g = Grid.new(rand_points)

    20.times do
      system('clear')
      puts g
      g = g.evolve
      sleep(0.1)
    end
  end

  class Grid

    attr_accessor :points

    def initialize(points)
      @points = Set.new(points)
    end

    def points_to_check
      all_points = []
      self.points.map do |point|
        neighbors(point[0], point[1]).map {|p| all_points.push(p) }
      end
      all_points
    end

    def point_is_alive?(x, y)
      self.points.include? [x, y]
    end

    def point_living_neighbor_count(x, y)
      neighbors(x, y).select do |neighbor|
        point_is_alive?(neighbor[0], neighbor[1]) &&
        !(neighbor[0] == x && neighbor[1] == y)
      end.count
    end

    def neighbors(x, y)
      neighbors = []
      (-1..1).each do |x_offset|
        (-1..1).each do |y_offset|
          neighbors.push([(x + x_offset), (y + y_offset)])
        end
      end
      neighbors
    end

    def point_starves(x, y)
      point_living_neighbor_count(x, y) < 2
    end

    def point_is_overpopulated(x, y)
      point_living_neighbor_count(x, y) > 3
    end

    def point_is_resurrected(x, y)
      !point_is_alive?(x, y) &&
      point_living_neighbor_count(x, y) == 3
    end

    def point_should_live?(x, y)
      if point_is_alive?(x, y)
        !(point_is_overpopulated(x, y) || point_starves(x, y))
      else
        point_is_resurrected(x, y)
      end
    end

    def evolve
      self.class.new(points_to_check.select {|p| point_should_live?(p[0], p[1])})
    end

    # Methods for displaying
    def sorted_points
      points.sort {|a,b| b[1] <=> a[1]}.sort {|a,b| a[0] <=> b[0]}
    end

    def bottom_left
      sorted_points.first
    end

    def top_right
      sorted_points.last
    end

    def to_s
      res = ""
      top_right[1].downto(bottom_left[1]).each do |y|
        bottom_left[0].upto(top_right[0]).each do |x|
          res += self.point_is_alive?(x,y) ? Conway::LIVE_CELL : Conway::DEAD_CELL
        end
        res += "\n"
      end
      res[0...-1]
    end
  end
end
