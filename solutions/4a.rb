start_val = ARGV[0].to_i || raise("missing start")
end_val = ARGV[1].to_i || raise("missing end")

def get_digits(num)
	digits = Array.new

	current_digs = num
	while current_digs > 0
		digit = current_digs % 10
		current_digs /= 10

		digits.push(digit)
	end
	return digits
end

def has_duplicate_digits(num)
	digits = get_digits(num)
	len = digits.length

	digits.each_with_index do |digit, digindex|
		if (digindex+1 < len) && digit.to_i == digits[digindex+1].to_i
			return true
		end
	end
	return false
end

def does_not_decrease_digits(num)
	digits = get_digits(num)
	len = digits.length
	prev_digit = digits[0]

	digits.each do |curr_digit|
		if (prev_digit < curr_digit)
			return false
		end
		prev_digit = curr_digit
	end
	return true
end


# puts has_duplicate_digits(123789)
# puts does_not_decrease_digits(123789)

count = 0
for i in start_val..end_val
	if (has_duplicate_digits(i) && does_not_decrease_digits(i))
		count +=1
	end
end

puts count