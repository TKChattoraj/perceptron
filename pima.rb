# /Users/tarunchattoraj/RubymineProjects/matrix/matrix-start.rb



require 'matrix'
require 'csv'
require 'rinruby'


# Read in the data--This will be an array of arrays
input_file_array = CSV.read('pima_input.csv', converters: :numeric)


# Shortened input file array:

#input_file_array = [[6,148,72,35,0,33.6,0.627,50,1], [1,85,66,29,0,26.6,0.351,31,0], [8,183,64,0,0,23.3,0.672,32,1], [1,89,66,23,94,28.1,0.167,21,0]]

#
# class_0_inputs = []
# class_1_inputs =[]
#
# input_file_array.each do |input_data_row|
# #   # Class is given as last element in row--9th element--as either a 0 or 1
#   if input_data_row[8] == 0
#     class_0_inputs << input_data_row.take(8)
#   elsif input_data_row[8] == 1
#     class_1_inputs << input_data_row.take(8)
#   else
#   end
# end
# puts "Which data should be the x axis? Enter a number 0-7."
# x = gets.chomp.to_f
#
# puts "Which data should be the y axis?  Enter a number 0-7."
# y = gets.chomp.to_f
#
# class0_x_data = []
# class0_y_data = []
#
# class1_x_data = []
# class1_y_data = []
#
# class_0_inputs.each do |i|
#   class0_x_data << i[x]
#   class0_y_data << i[y]
# end
#
# class_1_inputs.each do |i|
#   class1_x_data << i[x]
#   class1_y_data << i[y]
# end
#
# R.assign "class0_x_data", class0_x_data
# R.assign "class0_y_data", class0_y_data
# R.assign "class1_x_data", class1_x_data
# R.assign "class1_y_data", class1_y_data


# R.eval <<EOF
#   pdf("myplotpdf.pdf")
#   #  Class 0 is red diamonds.  col=2 is red color and pch=5 is diamond shape
#   plot(class0_x_data, class0_y_data, col=2, pch=5)
#   #  Class 1 is green triangles.  col=3 is green color and pch=2 is triangle
#   points(class1_x_data, class1_y_data, col=3, pch=2)
#   dev.off()
# EOF




class Perceptron
  # file_array is the input file-each row is a combination of the input vector and the target vector
  # n_input is the dimension of the input vector
  def initialize(file_array, n_input)
    input_row_array = []
    target_row_array = []
    file_array.each do |file_row|
       new_input_row = file_row.slice(0...n_input)
       input_row_array<<new_input_row
       new_target_row = file_row.slice(n_input..file_row.length-1)
       target_row_array<<new_target_row
    end
    @input_matrix = Matrix.rows(input_row_array)
    @target_matrix = Matrix.rows(target_row_array)

    weight_matrix_columns = @target_matrix.column_size
    weight_matrix_rows = @input_matrix.column_size
    @weight_matrix = Matrix.build(weight_matrix_rows, weight_matrix_columns){rand*0.1-0.05}
    @eta = 0.25

  end

  def input_matrix
    @input_matrix
  end

  def target_matrix
    @target_matrix
  end

  def weight_matrix
    @weight_matrix
  end

  def eta
    @eta
  end

  def eta=(eta)
    @eta = eta
  end

  def train
    iterations = 100
    trainned = false
    i = 0

    while ((i < iterations) && !trainned )
      puts i
      x_matrix = Matrix[@input_matrix.row(i)]
      output_matrix = @input_matrix * @weight_matrix

      activation_matrix = output_matrix.map do |y|
        if y > 0
          1
        else
          0
        end
      end

      delta = @eta*(@input_matrix.transpose * (activation_matrix - @target_matrix))

       @weight_matrix = @weight_matrix - delta
       puts @weight_matrix
      i +=1
    end

  end

  def predict

    y = @input_matrix * @weight_matrix
    activation_matrix = y.map do |y|
      if y > 0
        1
      else
        0
      end
    end

    confusion_array = [[0,0], [0,0]]
    activation_matrix.each_with_index do |result, row, col|
      t = @target_matrix[row, 0]
      confusion_array[t][result]  += 1
    end
    confusion_matrix = Matrix.rows(confusion_array)
    puts confusion_matrix
  end

end

def normalize_vector(vector)
  # normalize a vector
  # calculate its mean and variance ddof=0--denominator = length
  # output is an array
  array = vector.to_a()
  puts array
  R.assign "column", array

  R.eval <<EOF
  x <- mean(column)
  length = length(column)
  variance = var(column) * (length-1)/length
  column_norm = (column - x)/variance
EOF

  mean = R.pull "x"
  var = R.pull "variance"
  normalize = R.pull "column_norm"
  puts mean
  puts var
  puts normalize
  #normalize is an array
  normalize
end



def build_normalized_matrix(matrix)
  count = matrix.column_count
  column_array = []
  (0...count).each do |index|
    column = normalize_vector(matrix.column(index))
    column_array << column
  end
  normalized_matrix = Matrix.columns(column_array)
end

def add_bias_input_column(matrix)
  rows_array = matrix.to_a
  count = rows_array.count
  new_rows_array = []
  (0...count).each do |index|
    new_row = [-1] + rows_array[index]
    new_rows_array << new_row
  end
  matrix_with_bias = Matrix.rows(new_rows_array)
end


pcn = Perceptron.new(input_file_array, 8)

normalized_input_matrix = build_normalized_matrix(pcn.input_matrix)
normalized_input_matrix_with_bias = add_bias_input_column(normalized_input_matrix)
puts normalized_input_matrix_with_bias
#pcn.train
#pcn.predict



# input_file_index = input_file_array[0][0]
# input_matrix_range = 1..input_file_index #ranges of the number of input vectors
# input_matrix = Matrix[] #creates a matrix of all possible input vectors, each row is an input vector
#
# input_matrix_range.each do |row|
#   new_row = [-1] + input_file_array[row]
#   input_matrix = Matrix.rows(input_matrix.to_a<<new_row)
# end
# puts input_matrix
#
# input_file_index+=1
# target_vector = Matrix[input_file_array[input_file_index]] #all the correct outputs as a one row matrix
# puts target_vector
#
# input_file_index+=1
# eta = input_file_array[input_file_index][0]
# puts eta
#
# input_file_index+=1
# weight_matrix_column_size = input_file_array[input_file_index][0]
# weight_matrix = Matrix.build(input_matrix.column_size, weight_matrix_column_size){ rand }
# puts weight_matrix
#
#
# input_matrix_pointer = 0 #gives the location of the current input vector
# success = false #determines whether we have all inputs returning correct results
# success_tracker = 0 #tracks how many inputs in a row give correct answers
#
# until success
#   puts '************************'
#   puts "Input Matrix Pointer: "
#   puts input_matrix_pointer
#   puts "Weight Matrix: "
#   puts weight_matrix
#
#   x_matrix = Matrix[input_matrix.row(input_matrix_pointer)]
#   t = target_vector.column(input_matrix_pointer).[](0)
#   y_matrix = x_matrix * weight_matrix
#   y = y_matrix[0,0]
#   puts "Y:"
#   puts y
#   if y > 0
#     result = 1
#   else result = 0
#
#   end
#   if result == t
#     hit_target = true
#     success_tracker += 1
#     if success_tracker == input_matrix.row_count
#       success = true
#     end
#
#    else
#     hit_target = false
#     success_tracker = 0
#
#     weight_matrix = weight_matrix + eta*(t-y)* x_matrix.transpose # re-calculate the weight matrix
#
#   end
#   puts "Hit Target?"
#   puts hit_target
#   input_matrix_pointer = (input_matrix_pointer+=1) % input_matrix.row_count if success == false
#   puts "Sucess (True or False): "
#   puts success
#     puts '************************'
# end
#
# puts '+++++++++++++++'
# puts 'Finished and the Weight Matrix is:'
# puts weight_matrix
# puts '+++++++++++++++'
#
# puts 'Do you want to try it out (Y/N)?'
# answer = gets.chomp
# while answer == 'Y' || answer == 'y'
#   puts 'Input values x,y'
#   input = gets.chomp.split(',')
#   input = input.map{|a| a.to_f}
#   input = [-1] + input
#   i_matrix = Matrix[input]
#
#   output = i_matrix * weight_matrix
#   puts "output from input:"
#   puts output
#
#   yout = output[0,0]
#   if yout > 0
#     result = 1
#   else result = 0
#
#   end
#   puts "Result:"
#   puts result
#
#   puts "Another (Y/N)?"
#   answer = gets.chomp
#
#
#
# end

puts 'See ya!'
