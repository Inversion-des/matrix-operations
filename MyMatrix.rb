class MyMatrix
	attr_reader :rows

	def initialize(rows)
		# check the input data
		error_msg = case
			when !rows.is_a?(Array)
				'We expect an array of arrays (rows) as an argument'
			when !rows.all?{|row| row.is_a?(Array) }
				'Each row should be an array'
			when !rows.all?{|row| row.length == rows.first.length }
				'All the rows should have the same length'
			when !rows.flatten(1).all?{|el| el.is_a?(Numeric) }
				'All the elements should be numeric'
		end
		raise ArgumentError, error_msg if error_msg

		@rows = rows
	end


	# ----------------- MAIN math methods -----------------

	# compares two matrices
	def ==(other_matrix)
		raise ArgumentError, 'Matrix can be compared only with a matrix' unless other_matrix.is_a?(self.class)
		other_matrix.size == size && other_matrix.rows == @rows
	end

	# returns a new matrix with the columns as rows
	def transpose
		self.class.new cols
	end

	# add two matrices
	def +(other_matrix)
		raise ArgumentError, 'Matrix can be added only with a matrix' unless other_matrix.is_a?(self.class)
		raise ArgumentError, 'Matrices should be of the same size' if size != other_matrix.size

		# result elements equal to the sum of respective elements of the original matrices
		result_rows = []
		@rows.zip(other_matrix.rows).map do |row1, row2|
			result_row = row1.zip(row2).map &:sum
			result_rows << result_row
		end
		self.class.new result_rows
	end

	# subtract two matrices
	def -(other_matrix)
		raise ArgumentError, 'Matrix can be subtracted only with a matrix' unless other_matrix.is_a?(self.class)

		# result elements equal to the subtraction (via sum with negative value) of respective elements of the original matrices
		self + -other_matrix
	end

	# multiply
	def *(other_matrix_or_vector)
		# matrix x matrix
		if other_matrix_or_vector.is_a?(self.class)
			other_matrix = other_matrix_or_vector

			# check if matrices are conformable for multiplication
			raise ArgumentError, 'Matrices should be conformable for multiplication (number of columns of the left matrix is the same as the number of rows of the right matrix)' if cols.count != other_matrix.rows.count

			# result elements equal to the sum of products of respective elements of the original matrices
			result_rows = []
			for row in @rows
				result_row = []
				for col in other_matrix.cols
					result_row << row.zip(col).sum {|el1, el2| el1*el2 }
				end
				result_rows << result_row
			end
			self.class.new result_rows

		# matrix x vector
		elsif other_matrix_or_vector.is_a?(MyVector)
			vector = other_matrix_or_vector

			# check if matrix and vector are conformable for multiplication
			raise ArgumentError, 'Matrix and vector should be conformable for multiplication (number of columns of the matrix is the same as the number of rows of the vector)' if cols.count != vector.size

			col_matrix = self.class.new([vector]).transpose
			MyVector.new (self * col_matrix).cols[0]
		else
			raise ArgumentError, 'Matrix can be multiplied only with a matrix or vector'
		end
	end

	# returns structure like: {:value=>-3, :indexes=>[[0, 1], [1, 0]]}
	def min_els
		res = {value: Float::INFINITY, indexes:[]}
		@rows.each_with_index.map do |row, i|
			row.each_with_index.map do |el, j|
				if el < res[:value]
					res[:value] = el
					res[:indexes].clear << [i, j]
				elsif el == res[:value]
					res[:indexes] << [i, j]
				end
			end
		end
		res
	end
	def max_els
		# using .min_els but change the sign of the value
		(-self).min_els.tap {|res| res[:value] *= -1 }
	end

	# returns array of each point data like: [{:value=>2, :position=>[1, 2]}, …]
	def saddle_points
		# edge case: when all elements are the same — no saddle points
		return [] if min_els[:value] == max_els[:value]

		saddle_point_data = []
		@rows.each_with_index.map do |row, i|
			row_min, row_max = row.min, row.max
			row.each_with_index.map do |el, j|
				# saddle point condition
				if el == row_min && el == cols[j].max  ||  el == row_max && el == cols[j].min
					saddle_point_data << {value: el, position: [i, j]}
				end
			end
		end
		saddle_point_data
	end

	# returns a value of the some norm of the matrix
	def norm(type)
		case type
			when :Frobenius
				# Frobenius norm of a matrix
				Math.sqrt( @rows.flatten.sum {|el| el**2 } )
			when :infinity
				# infinity norm of a matrix, also known as the maximum absolute row sum norm
				@rows.map{|row| row.sum &:abs }.max
			when :one
				# 1-norm of a matrix, also known as the maximum absolute column sum norm
				cols.map{|col| col.sum &:abs }.max
			else
				raise ArgumentError, 'Type should be :Frobenius, :infinity or :one'
		end
	end


	# ----------------- helper methods -----------------

	# returns an array of columns
	def cols
		cols = []
		for row in @rows
			row.each_with_index do |element, i|
				(cols[i] ||= []) << element
			end
		end
		cols
	end

	# returns new matrix with all elements multiplied by -1
	def -@
		map {|el| -el }
	end

	# returns new matrix that is the result of iteration of the block over all elements
	def map
		result_rows = @rows.map do |row|
			row.map {|el| yield el }
		end
		self.class.new result_rows
	end

	# returns all matrix elements as an array of rows
	def to_a
		@rows
	end

	# returns string like '3 × 2'
	def size
		"#{@rows.count} × #{cols.count}"
	end

	# prints the matrix in a nice aligned multiline form
	def to_s
		text = "#{self.class} #{size}:\n"
		for row in @rows
			text << row.map{|el| "%3d" % el }.join + "\n"
		end
		text
	end
end