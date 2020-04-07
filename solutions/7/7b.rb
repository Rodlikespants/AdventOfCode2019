require 'pry'

class OperationResult
	attr_reader :intcode, :output
	def initialize(intcode, output=nil)
		@intcode = intcode
		@output = output
	end
end

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
		return OperationResult.new(inputs)
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
		return OperationResult.new(inputs)
	end
end

class Input < Operation
	def initialize(mode1, mode2, mode3, input_prompt)
		super(3, mode1, mode2, mode3, 2)
		@input_prompt = input_prompt
	end


	def process(inputs, pos)
		# input_value = "5".chomp.to_i
		if (@input_prompt.nil?)
			input_value = $stdin.gets.chomp.to_i
		else
			puts "Using input prompt " + @input_prompt.to_s
			input_value = @input_prompt
		end
		
		dest_index  = get_index(inputs, @mode1, pos, 1)
		inputs[dest_index] = input_value
		return OperationResult.new(inputs)
	end
end

class Output < Operation
	def initialize(mode1, mode2, mode3)
		super(4, mode1, mode2, mode3, 2)
	end

	def process(inputs, pos)
		param1_index = get_index(inputs, @mode1, pos, 1)
		output = inputs[param1_index].to_s
		puts "Diagnostic Result: " + output
		return OperationResult.new(inputs, output)
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

		# p inputs
		return OperationResult.new(inputs)
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

		return OperationResult.new(inputs)
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

		return OperationResult.new(inputs)
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
		
		return OperationResult.new(inputs)
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

def process_operation(full_code, input_prompt=nil)
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
		return Input.new(mode1, mode2, mode3, input_prompt)
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

def compute(og_inputs, noun=nil, verb=nil, phase=nil, thruster_input=nil)
	inputs = og_inputs.clone
	# p inputs
	if (!noun.nil?)
		inputs[1] = noun
	end

	if (!verb.nil?)
		inputs[2] = verb
	end

	pos = 0

	input_prompt = phase
	op = process_operation(inputs[pos], input_prompt)
	num_input_prompts = 0
	output = nil

	if (op.opcode == 3)
		num_input_prompts += 1
	end

	while (op.opcode != 99 && pos < inputs.size)
		p inputs[pos..(pos+op.instruction_offset-1)]

		# ugly hardcoded logic here
		if (op.opcode == 3)
			if (num_input_prompts > 0)
				input_prompt = thruster_input
			end
			num_input_prompts += 1
		end

		result = op.process(inputs, pos)
		inputs = result.intcode

		# hardcoded for this level?
		if (!result.output.nil?)
			output = result.output
		end

		pos += op.instruction_offset
		op = process_operation(inputs[pos], input_prompt)
	end

	puts output
	puts op.opcode
	return inputs[0], output.to_i, op.opcode == 99
end

def simulate_thrusters(intcode)
	max_output = 0
	max_perm = nil
	phase_perms = [0,1,2,3,4].permutation.to_a
	phase_perms.each do | phases |
		thruster_code = 0
		puts "phase_perm: #{phases}"
		phases.each do | phase |
			thruster_inputs = intcode.clone
			last_result, thruster_code = compute(thruster_inputs, nil, nil, phase, thruster_code)
			puts "new thruster code=#{thruster_code}"
			if (thruster_code > max_output)
				max_output = thruster_code
				max_perm = phases
			end
		end
		puts "Max output: #{max_output}"
	end
	# binding.pry
	return max_output, max_perm
end

# like the previous method except again with new phase settings
def simulate_thruster_feedback(intcode)
	max_output = 0
	max_perm = nil
	count = 0
	# phase_perms = [5,6,7,8,9].permutation.to_a
	phase_perms = [[9,8,7,6,5]]
	phase_perms.each do | phases |
		# thruster_code = input
		thruster_code = 0

		puts "phase_perm: #{phases}"
		cycle = phases.cycle
		phase = cycle.next
		exited = false
		while (count < 25)
			puts "phase=#{phase}"
			thruster_inputs = intcode.clone
			last_result, thruster_code, exited = compute(thruster_inputs, nil, nil, phase, thruster_code)
			puts "new thruster code=#{thruster_code} on phase=#{phase}"
			if (thruster_code > max_output)
				max_output = thruster_code
				max_perm = phases
			end
			phase = cycle.next
			count += 1
		end
		puts "Max feedback output: #{max_output}"
	end
	return max_output, max_perm
end

filename = ARGV[0] || raise("missing filename")


file = File.open(filename, "r")

og_inputs = Array.new
intputs = nil

file.each_line do |line|
	og_inputs = line.split(',')
	intputs = og_inputs.map(&:to_i)
end

# binding.pry

# output, phase = simulate_thrusters(intputs)
puts "FIRST PHASE COMPLETE\n\n\n"
feedback_output, feedback_phase = simulate_thruster_feedback(intputs)

# puts "Max output: #{output}"
# puts "Phase setting: #{phase}"

puts "Max Feedback Output: #{feedback_output}"
puts "Max Feedback Phase Setting: #{feedback_phase}"