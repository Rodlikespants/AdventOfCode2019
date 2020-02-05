require 'set'

class Point
	attr_accessor :x_coord, :y_coord
	def initialize(x_coord, y_coord)
		@x_coord = x_coord
		@y_coord = y_coord
	end

	def taxi_distance
		return @x_coord.abs + @y_coord.abs
	end

	def ==(other)
		return (@x_coord == other.x_coord) && (@y_coord == other.y_coord)
	end

	def eql?(other)
		return (@x_coord.eql?(other.x_coord)) && (@y_coord.eql?(other.y_coord))
	end

	def hash
		@x_coord.hash ^ @y_coord.hash
	end

	def to_s
		"("+@x_coord.to_s+","+@y_coord.to_s+")"
	end
end

def generate_points(inputs)
	points_set = Set.new
	prev_point = Point.new(0,0)
	points_set.add(prev_point)

	inputs.each do | instruction |
		if instruction =~ /(\w)(\d+)/
			direction = $1
			steps = $2.to_i
			if (direction.eql?("U"))
				for i in 1..steps do
					prev_point = Point.new(prev_point.x_coord, prev_point.y_coord+1)
					points_set.add(prev_point)
				end
			elsif (direction.eql?("D"))
				for i in 1..steps do
					prev_point = Point.new(prev_point.x_coord, prev_point.y_coord-1)
					points_set.add(prev_point)
				end
			elsif (direction.eql?("L"))
				for i in 1..steps do
					prev_point = Point.new(prev_point.x_coord-1, prev_point.y_coord)
					points_set.add(prev_point)
				end
			elsif (direction.eql?("R"))
				for i in 1..steps do
					prev_point = Point.new(prev_point.x_coord+1, prev_point.y_coord)
					points_set.add(prev_point)
				end
			end
		end
	end

	return points_set
end


filename = ARGV[0] || raise("missing filename")

file = File.open(filename, "r")

# 2D array
og_inputs = Array.new(0)

file.each_line do |line|
	og_inputs.push(line.split(','))
end


# first wire
points_set1 = generate_points(og_inputs[0])

points_set1.each do |x|
	puts x.to_s
end

puts ""

# second wire
points_set2 = generate_points(og_inputs[1])

points_set2.each do |x|
	puts x.to_s
end

puts "Intersection: "
intersection = (points_set1 & points_set2).to_a
=begin
intersection = Set.new
points_set1.each do |x|
	if points_set2.include?(x)
		puts x.to_s
		intersection.add(x)
		exit
	end
end
=end

intersection = intersection.sort { |a, b| a.taxi_distance <=> b.taxi_distance}

closest_intersection = intersection[1]
puts closest_intersection.taxi_distance