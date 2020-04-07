filename = ARGV[0] || raise("missing filename")


file = File.open(filename, "r")

inputs = Array.new
file.each_line do |line|
	inputs = line.split(',')
end

p inputs

pos = 0
opcode = inputs[pos].to_i

while (opcode != 99 && pos < inputs.size)
	if (opcode == 1)
		inputs[inputs[pos+3].to_i] = inputs[inputs[pos+1].to_i].to_i + inputs[inputs[pos+2].to_i].to_i
	elsif (opcode == 2)
		inputs[inputs[pos+3].to_i] = inputs[inputs[pos+1].to_i].to_i * inputs[inputs[pos+2].to_i].to_i
	else
		puts "WARNING: unknown opcode=#{opcode}"
		exit
	end
	pos += 4
	opcode = inputs[pos].to_i
	p inputs
end

puts inputs[0]

# puts inputs.size