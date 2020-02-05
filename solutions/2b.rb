def compute_all(og_inputs, result)
	for i in 0..99
		for j in 0..99
			computed_result = compute(og_inputs,i,j)
			if (result == computed_result)
				return i, j
			end
		end
	end
end

def compute(og_inputs, noun, verb)
	inputs = og_inputs.clone
	# p inputs
	inputs[1] = noun
	inputs[2] = verb

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
		# p inputs
	end

	return inputs[0]
end

filename = ARGV[0] || raise("missing filename")
result = ARGV[1] || raise('missing result')


file = File.open(filename, "r")

og_inputs = Array.new
file.each_line do |line|
	og_inputs = line.split(',')
end

noun,verb = compute_all(og_inputs, result.to_i)

puts "noun=#{noun}, verb=#{verb}"


# puts inputs.size