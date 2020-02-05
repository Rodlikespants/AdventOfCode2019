filename = ARGV[0] || raise("missing filename")

def compute_fuel(mass)
	return (mass/3) - 2
end

def fuelception(fuel)
	p fuel
	fuel_fuel = compute_fuel(fuel)
	p fuel_fuel
	if (fuel_fuel > 0)
		return fuel_fuel + fuelception(fuel_fuel);
	else
		return 0
	end
end

file = File.open(filename, "r")

fuel = 0
file.each_line do |mass|
	# puts mass
	fuel += fuelception(mass.to_i)
end
puts fuel