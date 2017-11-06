# /Users/tarunchattoraj/RubymineProjects/matrix/matrix-start.rb

require 'matrix'
require 'csv'
require 'rinruby'


# Read in the data--This will be an array of arrays
input_file_array = CSV.read('pima_input.csv', converters: :numeric)
#input_file_array = CSV.read('parity_input.csv', converters: :numeric)
#input_file_array = CSV.read('nand_input.csv', converters: :numeric)

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
    @input_matrix = add_bias_input_column(@input_matrix)
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

  def batch_train(input_matrix)
    iterations = 200
    untrained = true
    i = 0

    while ((i < iterations) && untrained )
      puts i
      # train by batch inputs.

      output_matrix = input_matrix * @weight_matrix
      # Perform the threshold function.  If output is greater than 0 repalce with 1.  If not replace with 0.
      activation_matrix = output_matrix.map do |y|
        if y > 0
          1
        else
          0
        end
      end

      delta = @eta*(input_matrix.transpose * (activation_matrix - @target_matrix))
      if delta.zero?
        untrained = false
      else
         @weight_matrix = @weight_matrix - delta
         puts "Weight Matrix"
         puts @weight_matrix
      end
      i +=1
    end
    if (i==iterations)
      puts "Perceptron did NOT learn."
    else
      puts "Perceptron learned."
      puts @weight_matrix
    end
  end

  def train(input_matrix)
    iterations = 100
    untrained = true
    errorless_count = 0
    i = 0

    while ((i < iterations) && untrained )
      puts i
      # input_row_index is needed to cycle through the input rows until Perceptron learns
      input_row_index = i%200
      puts "input row index"
      puts input_row_index
      input_row = Matrix[input_matrix.row(input_row_index)]
      puts "input_row/target_row/output_row/activation_row"
      puts input_row
      target_row = Matrix[@target_matrix.row(input_row_index)]
      output_row = input_row * @weight_matrix
      puts target_row
      puts output_row
      # Perform the threshold function.  If output is greater than 0 repalce with 1.  If not replace with a 0.
      activation_row = output_row.map do |y|
        if y > 0
          1
        else
          0
        end
      end
      puts activation_row
      puts "delta"
      delta = @eta*(input_row.transpose * (activation_row - target_row))
      puts delta
      if delta.zero?
        errorless_count += 1
        puts "delta is zero"
      else
         errorless_count = 0
         @weight_matrix = @weight_matrix - delta
         puts "Weight Matrix"
         puts @weight_matrix
      end
      if (errorless_count == input_matrix.row_count)
        untrained = false
      end
      i +=1
    end

    if (i==iterations)
      puts "Perceptron did NOT learn."
    else
      puts "Perceptron learned:"
      puts @weight_matrix
    end
  end



  def predict
    y = @input_matrix * @weight_matrix
    puts "Y Output Matrix"
    puts y
    activation_matrix = y.map do |y|
      if y > 0
        1
      else
        0
      end
    end
    puts "Activation Matrix"
    puts activation_matrix
    confusion_array = [[0,0], [0,0]]
    activation_matrix.each_with_index do |result, row, col|
      t = @target_matrix[row, col]
      confusion_array[t][result]  += 1
    end
    confusion_matrix = Matrix.rows(confusion_array)
  end
end
# end Class Perceptron


def plot_two_vectors(vector1, vector2)
# Plots two vectors where x axis is the vector position.
# Fore example, x axis is 0 then y is vector[0]
  array1 = vector1.to_a[0...50]
  array2 = vector2.to_a[0...50]

  R.assign "array1", array1
  R.assign "array2", array2

R.eval <<EOF
  pdf("vector_plots.pdf")
  # print plot to a file vector_plots.pdf
  plot(array1, type="o", col="blue")
  lines(array2, type="o", pch=22, lty=2, col="red")
  dev.off()
EOF
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

  # check to see if the variance = 0, meaning all the data in a column is the same
  # if so, the the column values should be set to zero.
  # Need to think about whether this is a valid assumption.
  # It seems to be as it will maintain the shape of the column vector

  if (variance == 0) {
    column_norm = column - column
  } else {
    column_norm = (column - x)/variance
  }

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

###### End of Methods ###########



#normalized_input_matrix = build_normalized_matrix(pcn.input_matrix)

#normalized_column = normalized_input_matrix.column(0)
#input_column = pcn.input_matrix.column(0)
#plot_two_vectors(input_column, normalized_column)
puts "************************************************************************"
puts "************************************************************************"
puts "************************************************************************"
puts "************************************************************************"
puts "************************************************************************"
puts "************************************************************************"
puts "************************************************************************"
puts "************************************************************************"
puts "train"
simple_train = Perceptron.new(input_file_array, 8)
simple_train.train(build_normalized_matrix(simple_train.input_matrix))
simple_train_confusion = simple_train.predict
simple_percentage = (simple_train_confusion[0,0]+simple_train_confusion[1,1]).fdiv(simple_train_confusion[0,0]+simple_train_confusion[1,1]+ simple_train_confusion[0,1]+simple_train_confusion[1,0])

puts "00000000000000000000000000000000000000000000000000000000000000000000000"
puts "00000000000000000000
000000000000000000000000000000000000000000000000000"
puts "00000000000000000000000000000000000000000000000000000000000000000000000"
puts "00000000000000000000000000000000000000000000000000000000000000000000000"
puts "00000000000000000000000000000000000000000000000000000000000000000000000"
puts "00000000000000000000000000000000000000000000000000000000000000000000000"
puts "00000000000000000000000000000000000000000000000000000000000000000000000"
puts "00000000000000000000000000000000000000000000000000000000000000000000000"
puts "batch_train"
batch_train = Perceptron.new(input_file_array, 8)
batch_train.batch_train(build_normalized_matrix(batch_train.input_matrix))
batch_train_confusion = batch_train.predict
batch_percentage = (batch_train_confusion[0,0]+batch_train_confusion[1,1]).fdiv(batch_train_confusion[0,0]+batch_train_confusion[1,1]+batch_train_confusion[0,1]+batch_train_confusion[1,0])
puts "simple confusion"
puts simple_train_confusion
puts simple_percentage
puts "batch confusion"
puts batch_train_confusion
puts batch_percentage


puts 'See ya!'
