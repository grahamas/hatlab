function [ output_str ] = zero_pad_str( num_str, desired_length )

num_zeros = desired_length - length(num_str);
zeros = repmat('0', 1, num_zeros);
output_str = [zeros, num_str];

end

