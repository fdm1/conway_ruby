require "set"

module Conway
  DEAD_CELL = " "
  LIVE_CELL = "\u2588"
  DEFAULT_SIZE = 30
  DEFAULT_NRUNS = 100

  class CLI
    def self.parse!(argv)
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: conway [options]"

        opts.on("-h", "--height=height", Integer, "height") do |height|
          options[:height] = height
        end

        opts.on("-w", "--width=width", Integer, "width") do |width|
          options[:width] = width
        end

        opts.on("-r", "--nruns=nruns", Integer, "N number of runs") do |nruns|
          options[:nruns] = nruns
        end

        opts.separator ""

        opts.on("--help", "Show this help message.") do
          puts opts
          exit
        end
      end

      opt_parser.parse! argv
      puts options
      options
    end

    def self.run(argv)
      options = parse!(argv)
      if (options[:height] && !options[:width])
        options[:width] = options[:height]
      end

      if (options[:width] && !options[:height])
        options[:height] = options[:width]
      end

      Conway.run(options)
    end
  end

  def self.run(options)
    height = options[:height] || DEFAULT_SIZE
    width = options[:width] || DEFAULT_SIZE
    nruns = options[:nruns] || DEFAULT_NRUNS

    g = Grid.new(width, height)

    nruns.times do |i|
      system('clear')
      puts g
      sleep(0.2)
      g = g.evolve
    end
  end

  class Grid

    attr_accessor :points, :width, :height

    def initialize(width, height, points=nil)
      @width = width
      @height = height
      @points = points ? Set.new(points) : _generate_points
      prune_points if points
    end

    def _generate_points
      rand_points = []
      (self.width*self.height*0.2).to_i.times do |i|
        rand_points.push([(0..self.width).to_a[rand(self.width)],
                          (0..self.height).to_a[rand(self.height)]])
      end
      rand_points
    end

    def prune_points
      self.points.reject! do |p|
        p[0] < -1 ||
        p[0] > self.width + 1  ||
        p[1] > self.height + 1  ||
        p[1] < -1
      end
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
      self.class.new(self.width, self.height, points_to_check.select {|p| point_should_live?(p[0], p[1])})
    end

    # Methods for displaying
    def sorted_points
      points.sort {|a,b| b[1] <=> a[1]}.sort {|a,b| a[0] <=> b[0]}
    end

    def to_s
      res = ""
      (self.height + 1).downto(-1).each do |y|
        (-1).upto(self.width + 1).each do |x|
          res += self.point_is_alive?(x,y) ? Conway::LIVE_CELL : Conway::DEAD_CELL
        end
        res += "\n"
      end
      return res[0...-1]
    end
  end
end
