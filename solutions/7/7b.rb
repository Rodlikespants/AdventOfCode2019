require 'pry'

class Amplifier
	attr_reader :intcode, :phase, :terminated, :pos, :input_prompts, :output

	def initialize(og_inputs, phase)
		@intcode = og_inputs.clone
		@phase = phase
		@terminated = false
		@pos = 0
		@input_prompts = [phase]
		@output = 0
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
			return Input.new(mode1, mode2, mode3, @input_prompts.pop)
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

	def compute(thruster_input=nil)
		if (!thruster_input.nil?)
			@input_prompts.insert(0, thruster_input)
		end

		puts "input_prompts=" + @input_prompts.to_s

		op = self.process_operation(@intcode[@pos])
		taking_input = false

		while (!@terminated && @pos < @intcode.size && !taking_input)
			p @intcode[@pos..(@pos+op.instruction_offset-1)]

			result = op.process(@intcode, @pos)
			if (op.opcode == 3 && result.nil?)
				taking_input = true
				next
			end

			@intcode = result.intcode

			# hardcoded for this level?
			if (!result.output.nil?)
				@output = result.output.to_i
				puts "output changed to #{output}"
			end

			@pos += op.instruction_offset
			op = self.process_operation(@intcode[@pos])
			@terminated = op.opcode == 99
		end
	end
end

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
			# input_value = $stdin.gets.chomp.to_i
			# move onto next amplifier if no inputs
			return nil
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

# like the previous method except again with new phase settings
def simulate_thruster_feedback(intcode)
	max_output = 0
	max_perm = nil
	iterations = 0
	phase_perms = [5,6,7,8,9].permutation.to_a
	# phase_perms = [[9,8,7,6,5]]

	phase_perms.each do | phases |
		# thruster_code = input
		thruster_code = 0
		
		# initialize amplifiers to the phases
		amps = Array.new
		phases.each do | phase |
			amps.push(Amplifier.new(intcode, phase))
		end


		puts "phase_perm: #{phases}"
		cycle = amps.cycle
		amp = cycle.next
		while (!amp.terminated || !amp.eql?(amps.last))
			puts "\n[phase=" + amp.phase.to_s + "]"

			amp.compute(thruster_code)
			thruster_code = amp.output
			puts "new thruster code=#{thruster_code} on phase="+amp.phase.to_s

			if (thruster_code > max_output)
				max_output = thruster_code
				max_perm = phases
			end

			amp = cycle.next
			iterations += 1
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
feedback_output, feedback_phase = simulate_thruster_feedback(intputs)

# puts "Max output: #{output}"
# puts "Phase setting: #{phase}"

puts "Max Feedback Output: #{feedback_output}"
puts "Max Feedback Phase Setting: #{feedback_phase}"