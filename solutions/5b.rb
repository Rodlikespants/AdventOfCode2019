class Operation
	attr_reader :opcode, :mode1, :mode2, :mode3, :instruction_offset
	# attr_writer :instruction_offset
	def initialize(opcode, mode1, mode2, mode3, instruction_offset)
		@opcode = opcode
		@mode1 = mode1
		@mode2 = mode2
		@mode3 = mode3
		@instruction_offset = instruction_offset
	end

	def get_index(inputs, mode, instruction_pos, param_pos)
		ind = instruction_pos + param_pos
		if (mode == 0)
			return inputs[ind]
		elsif (mode == 1)
			return ind
		else
			raise "ERROR in get_index #{inputs} #{mode} #{instruction_pos} #{param_pos}"
		end
	end
end

class Addition < Operation
	def initialize(mode1, mode2, mode3)
		super(1, mode1, mode2, mode3, 4)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		param2_index = get_index(inputs, @mode2, pos, 2)
		dest_index   = get_index(inputs, @mode3, pos, 3)
		# puts "#{param1_index} #{param2_index} #{dest_index}"
		inputs[dest_index] = inputs[param1_index] + inputs[param2_index]
		return inputs
	end
end

class Multiplication < Operation
	def initialize(mode1, mode2, mode3)
		super(2, mode1, mode2, mode3, 4)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		param2_index = get_index(inputs, @mode2, pos, 2)
		dest_index   = get_index(inputs, @mode3, pos, 3)
		inputs[dest_index] = inputs[param1_index] * inputs[param2_index]
		return inputs
	end
end

class Input < Operation
	def initialize(mode1, mode2, mode3)
		super(3, mode1, mode2, mode3, 2)
	end


	def process(inputs, pos)
		# input_value = "5".chomp.to_i
		input_value = $stdin.gets.chomp.to_i
		
		dest_index  = get_index(inputs, @mode1, pos, 1)
		inputs[dest_index] = input_value
		return inputs
	end
end

class Output < Operation
	def initialize(mode1, mode2, mode3)
		super(4, mode1, mode2, mode3, 2)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		puts "Diagnostic Result: " + inputs[param1_index].to_s
		return inputs
	end
end

# TODO position mode jump tests input5b_test5.txt failing
class JumpIfTrue < Operation
	def initialize(mode1, mode2, mode3)
		super(5, mode1, mode2, mode3, 3)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		param2_index = get_index(inputs, @mode2, pos, 2)

		# move the instruction pointer and track the offset
		if (inputs[param1_index] != 0)
			@instruction_offset = inputs[param2_index] - pos
		end

		p inputs
		return inputs
	end
end

class JumpIfFalse < Operation
	def initialize(mode1, mode2, mode3)
		super(6, mode1, mode2, mode3, 3)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		param2_index = get_index(inputs, @mode2, pos, 2)

		# move the instruction pointer and track the offset
		if (inputs[param1_index] == 0)
			@instruction_offset = inputs[param2_index] - pos
		end

		return inputs
	end
end

class LessThan < Operation
	def initialize(mode1, mode2, mode3)
		super(7, mode1, mode2, mode3, 4)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		param2_index = get_index(inputs, @mode2, pos, 2)
		param3_index = get_index(inputs, @mode3, pos, 3)

		inputs[param3_index] = inputs[param1_index] < inputs[param2_index] ? 1 : 0

		return inputs
	end
end

class Equals < Operation
	def initialize(mode1, mode2, mode3)
		super(8, mode1, mode2, mode3, 4)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		param2_index = get_index(inputs, @mode2, pos, 2)
		param3_index = get_index(inputs, @mode3, pos, 3)

		inputs[param3_index] = inputs[param1_index] == inputs[param2_index] ? 1 : 0
		
		return inputs
	end
end

# don't think this works as intended with the processing loop
class Exit < Operation
	def initialize(mode1, mode2, mode3)
		super(99, mode1, mode2, mode3, 1)
	end

	def process(inputs, pos)
		# TODO better way to do this I'm sure
		exit
	end
end

def process_operation(full_code)
	opcode = full_code%100
	mode1 = (full_code/100)%10
	mode2 = (full_code/1000)%10
	mode3 = (full_code/10000)
	# puts "#{full_code}"

	num_positions = 0
	if (opcode == 1)
		return Addition.new(mode1, mode2, mode3)
	elsif (opcode == 2)
		return Multiplication.new(mode1, mode2, mode3)
	elsif (opcode == 3)
		return Input.new(mode1, mode2, mode3)
	elsif (opcode == 4)
		return Output.new(mode1, mode2, mode3)
	elsif (opcode == 5)
		return JumpIfTrue.new(mode1, mode2, mode3)
	elsif (opcode == 6)
		return JumpIfFalse.new(mode1, mode2, mode3)
	elsif (opcode == 7)
		return LessThan.new(mode1, mode2, mode3)
	elsif (opcode == 8)
		return Equals.new(mode1, mode2, mode3)
	elsif (opcode == 99)
		return Exit.new(mode1, mode2, mode3)
	else
		raise "Unknown operation full code #{full_code}"
	end
end

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

def compute(og_inputs, noun=nil, verb=nil)
	inputs = og_inputs.clone
	# p inputs
	if (!noun.nil?)
		inputs[1] = noun
	end

	if (!verb.nil?)
		inputs[2] = verb
	end

	pos = 0
	op = process_operation(inputs[pos])

	while (op.opcode != 99 && pos < inputs.size)
		p inputs[pos..(pos+op.instruction_offset-1)]
		op.process(inputs, pos)
		pos += op.instruction_offset
		# puts "offset="+op.instruction_offset.to_s
		# puts "pos=#{pos}"
		# puts inputs[pos]
		op = process_operation(inputs[pos])
		# p inputs
	end

	return inputs[0]
end

filename = ARGV[0] || raise("missing filename")
# result = ARGV[1] || raise('missing result')


file = File.open(filename, "r")

og_inputs = Array.new
intputs = nil

file.each_line do |line|
	og_inputs = line.split(',')
	intputs = og_inputs.map(&:to_i)
end

# noun,verb = compute_all(intputs, result.to_i)
# puts "noun=#{noun}, verb=#{verb}"
# puts compute(intputs, 12, 2)
puts compute(intputs)



# puts inputs.size