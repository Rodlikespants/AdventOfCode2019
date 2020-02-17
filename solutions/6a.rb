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

total_num_orbits = 0
bodies_map.keys.each do |key|
	num_orbits = calculate_num_orbits(bodies_map, key)
	total_num_orbits += num_orbits
end

puts total_num_orbits