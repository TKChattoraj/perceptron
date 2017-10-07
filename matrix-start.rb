# /Users/tarunchattoraj/RubymineProjects/matrix/matrix-start.rb



require 'matrix'
require 'csv'
require 'rinruby'

# Read in the data--input vector, target vector, eta, weight matrix size
input_file_array= CSV.read('input_file.csv', converters: :numeric)
input_file_index = input_file_array[0][0]
input_matrix_range = 1..input_file_index #ranges of the number of input vectors
input_matrix = Matrix[] #creates a matrix of all possible input vectors, each row is an input vector

input_matrix_range.each do |row|
  new_row = [-1] + input_file_array[row]
  input_matrix = Matrix.rows(input_matrix.to_a<<new_row)
end
puts input_matrix

input_file_index+=1
target_vector = Matrix[input_file_array[input_file_index]] #all the correct outputs as a one row matrix
puts target_vector

input_file_index+=1
eta = input_file_array[input_file_index][0]
puts eta

input_file_index+=1
weight_matrix_column_size = input_file_array[input_file_index][0]
weight_matrix = Matrix.build(input_matrix.column_size, weight_matrix_column_size){ rand }
puts weight_matrix


input_matrix_pointer = 0 #gives the location of the current input vector
success = false #determines whether we have all inputs returning correct results
success_tracker = 0 #tracks how many inputs in a row give correct answers

until success
  puts '************************'
  puts "Input Matrix Pointer: "
  puts input_matrix_pointer
  puts "Weight Matrix: "
  puts weight_matrix

  x_matrix = Matrix[input_matrix.row(input_matrix_pointer)]
  t = target_vector.column(input_matrix_pointer).[](0)
  y_matrix = x_matrix * weight_matrix
  y = y_matrix[0,0]
  puts "Y:"
  puts y
  if y > 0
    result = 1
  else result = 0

  end
  if result == t
    hit_target = true
    success_tracker += 1
    if success_tracker == input_matrix.row_count
      success = true
    end

   else
    hit_target = false
    success_tracker = 0

    weight_matrix = weight_matrix + eta*(t-y)* x_matrix.transpose # re-calculate the weight matrix

  end
  puts "Hit Target?"
  puts hit_target
  input_matrix_pointer = (input_matrix_pointer+=1) % input_matrix.row_count if success == false
  puts "Sucess (True or False): "
  puts success
    puts '************************'
end

puts '+++++++++++++++'
puts 'Finished and the Weight Matrix is:'
puts weight_matrix
puts '+++++++++++++++'

puts 'Do you want to try it out (Y/N)?'
answer = gets.chomp
while answer == 'Y' || answer == 'y'
  puts 'Input values x,y'
  input = gets.chomp.split(',')
  input = input.map{|a| a.to_f}
  input = [-1] + input
  i_matrix = Matrix[input]

  output = i_matrix * weight_matrix
  puts "output from input:"
  puts output

  yout = output[0,0]
  if yout > 0
    result = 1
  else result = 0

  end
  puts "Result:"
  puts result

  puts "Another (Y/N)?"
  answer = gets.chomp



end
puts 'See ya!'
