class Satellite
	attr_reader :code, :primary
	def initialize(code, primary)
		@code = code
		@primary = primary
	end
end

def calculate_num_orbits(bodies_map, satellite_code)
	num_orbits = 0
	while (!bodies_map[satellite_code].nil?)
		satellite_code = bodies_map[satellite_code]
		num_orbits += 1
	end
	return num_orbits
end

def lowest_common_ancestor_distance(bodies_map, code1, code2)
	curr_code = code1
	primaries1 = Array.new
	primaries1.push(curr_code)

	while (!bodies_map[curr_code].nil?)
		curr_code = bodies_map[curr_code]
		primaries1.push(curr_code)
	end

	p primaries1

	curr_code = code2
	primaries2 = Array.new
	primaries2.push(curr_code)
	while (!bodies_map[curr_code].nil? && !primaries1.include?(curr_code))
		curr_code = bodies_map[curr_code]
		primaries2.push(curr_code)
	end

	p primaries2

	lca_index = primaries1.index(curr_code)
	if (lca_index.nil?)
		lca_index = 0
	end

	distance1 = lca_index - 1
	distance2 = primaries2.length

	return distance1 + distance2
end

filename = ARGV[0] || raise("missing filename")

file = File.open(filename, "r")

# universal center of mass
ucom = Satellite.new("COM", nil)

# satellite code to primary code
bodies_map = Hash.new(0)
bodies_map[ucom.code] = nil

file.each_line do |line|
	bodies         = line.split(')')
	primary_code   = bodies[0].chomp
	satellite_code = bodies[1].chomp
	bodies_map[satellite_code] = primary_code
end

puts lowest_common_ancestor_distance(bodies_map, bodies_map["YOU"], bodies_map["SAN"])
