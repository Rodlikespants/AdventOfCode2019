class Node
   # @@no_of_customers = 0
   def initialize(next_node, prev, val)
      @next = next_node
      @prev = prev
      @val = val
   end
end


filename = ARGV[0] || raise("missing filename")


file = File.open(filename, "r")

inputs = Array.new
file.each_line do |line|
	inputs = line.split(',')
end

i = 0
while (i < inputs.size)
	p inputs[i..i+3]
	if ((inputs[i+3].to_i + 1) % 4 != 0) && inputs[i+3].to_i != 0 && inputs[i].to_i != 99
		puts "ERROR at "+(i+3).to_s+" "+inputs[i+3].to_s
	end
	i += 4
end

=begin

input_links = Array.new

# p inputs

pos = 0
opcode = inputs[pos].to_i
noun_index = pos + 1
verb_index = pos + 2
prev_noun_index = nil
prev_verb_index = nil

# insert initial nodes
input_links[pos] = Node.new(nil, nil, opcode, true)
# input_links[noun_index] = Node.new(input[])

while (opcode != 99 && pos < inputs.size)

	if (opcode == 1)
		# inputs[inputs[pos+3].to_i] = inputs[noun_index].to_i + inputs[verb_index].to_i
		input_links[noun_index] = Node.new(noun_index, prev_noun_index, inputs[noun_index])
		verb_node = Node.new(verb_index, prev_verb_index, inputs[verb_index])
		result_node = Node.new(nil, nil, inputs[noun_index].to_i + inputs[verb_index].to_i)

		prev_noun_index = noun_index
		prev_verb_index = verb_index

		noun_index = inputs[prev_noun_index].to_i
		verb_index = inputs[prev_verb_index].to_i
	elsif (opcode == 2)
		noun_index = inputs[pos+1].to_i
		verb_index = inputs[pos+2].to_i
		inputs[inputs[pos+3].to_i] = inputs[inputs[pos+1].to_i].to_i * inputs[inputs[pos+2].to_i].to_i
	else
		puts "WARNING: unknown opcode=#{opcode}"
		exit
	end
	pos += 4
	opcode = inputs[pos].to_i

	# insert a node for opcode
	input_links[pos] = Node.new(nil, nil, opcode, true)
	# p inputs
end

# puts inputs[0]

# begin to backup
end_pos = pos - 4
noun = nil
verb = nil

while (end_pos > 0)
	if (opcode == 1)
		noun = 
	elsif (opcode == 2)
	else
	end
end
=end