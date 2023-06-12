require 'matrix'  # require stdlib classes
# require our classes
require_relative 'MyVector'
require_relative 'MyMatrix'


RSpec.describe MyVector do
	describe 'constructor' do
		it 'works fine with the correct input data' do
			expect( MyVector.new(1,2,3) ).to be_a MyVector
			expect( MyVector.new([1, 2, -3]) ).to eq [1, 2, -3]
			expect( MyVector.new(1, 2.5, 3) ).to eq [1, 2.5, 3]
			expect( MyVector.new ).to eq []
			expect( MyVector.new([]) ).to eq []
			expect( MyVector.new([0]) ).to eq [0]
		end
		it 'raises an error when argument is not an array/list of numbers' do
			the_error = ArgumentError, 'All the elements should be numeric'
			expect{ MyVector.new({}) }.to raise_error *the_error
			expect{ MyVector.new(1,'2',3) }.to raise_error *the_error
			expect{ MyVector.new [1,nil,3] }.to raise_error *the_error
			expect{ MyVector.new [1,[2],3] }.to raise_error *the_error
		end
	end

	let :sample_vector do
		MyVector.new [1, 2, 3]
	end

	describe 'vector.scalar_product(other_vector)' do
		it 'returns a number' do
			expect( sample_vector.scalar_product(sample_vector) ).to be_a Numeric
		end
		it 'returns the scalar product of two vectors' do
			expect( sample_vector.scalar_product(sample_vector) ).to eq 14
			expect( sample_vector.scalar_product(MyVector.new(0,0,0)) ).to eq 0
			expect( sample_vector.scalar_product(MyVector.new([2,2,2])) ).to eq 12
		end
		it 'works the same as the stdlib Vector#inner_product' do
			v = Vector[*sample_vector.to_a]
			expect( sample_vector.scalar_product(sample_vector) ).to eq v.inner_product(v)
			expect( sample_vector.scalar_product(MyVector.new(0,0,0)) ).to eq v.inner_product(Vector[0,0,0])
			expect( sample_vector.scalar_product(MyVector.new([2,2,2])) ).to eq v.inner_product(Vector[2,2,2])
		end
		it 'raises an error if argument is not a vector' do
			the_error = ArgumentError, 'Vector can be multiplied only with a vector'
			expect{ sample_vector.scalar_product(1) }.to raise_error *the_error
			expect{ sample_vector.scalar_product('string') }.to raise_error *the_error
			expect{ sample_vector.scalar_product([1,2,3]) }.to raise_error *the_error
		end
		it 'raises an error if vectors are of different size' do
			the_error = ArgumentError, 'Vectors should be of the same size'
			expect{ sample_vector.scalar_product(MyVector.new([1,2])) }.to raise_error *the_error
			expect{ sample_vector.scalar_product(MyVector.new(1,2,3,4)) }.to raise_error *the_error
		end
	end
end

RSpec.describe MyMatrix do
	describe 'constructor' do
		it 'works fine with the correct input data' do
			m = MyMatrix.new [
				[ 1, -2,  3.0],
				[ 0,  5, -6.5]
			]
			expect( m.to_a ).to eq [[1, -2, 3.0], [0, 5, -6.5]]

			expect( MyMatrix.new([]).to_a ).to eq []
			expect( MyMatrix.new([[0]]).to_a ).to eq [[0]]
			expect( MyMatrix.new([[0,0],[0,0]]).to_a ).to eq [[0, 0], [0, 0]]
		end
		context 'raises an error when:' do
			example 'no argument is given' do
				expect{ MyMatrix.new }.to raise_error ArgumentError, /wrong number of arguments/
			end
			example 'argument is not an array' do
				expect{ MyMatrix.new(1) }.to raise_error ArgumentError, /expect an array/
			end
			example 'argument is not an array of arrays' do
				the_error = ArgumentError, 'Each row should be an array'
				expect{ MyMatrix.new [1,2,3] }.to raise_error *the_error
				expect{ MyMatrix.new [[1],2,[3]] }.to raise_error *the_error
			end
			example 'rows are not of the same length' do
				expect{ MyMatrix.new [[1,2],[3]] }.to raise_error ArgumentError, /same length/
			end
			example 'some element is not numeric' do
				the_error = ArgumentError, /should be numeric/
				expect{ MyMatrix.new [[1,'2'],[3,4]] }.to raise_error *the_error
				expect{ MyMatrix.new [[1,nil],[3,4]] }.to raise_error *the_error
				expect{ MyMatrix.new [[1,[2]],[3,4]] }.to raise_error *the_error
			end
		end
	end

	let :sample_matrix do
		MyMatrix.new [
			[ 1, -2],
			[ 3,  4],
			[15,  6]
		]
	end
	let :sample_matrix_with_multiple_min_max do
		MyMatrix.new [
			[ 15, -2],
			[ -2, 15],
			[ 15,  6]
		]
	end

	describe 'MAIN math methods' do
		describe 'matrix == matrix' do
			it 'returns true if matrices are equal' do
				expect( sample_matrix == sample_matrix ).to be true
				expect( sample_matrix == MyMatrix.new([[1,-2],[3,4],[15,6]]) ).to be true
				expect( sample_matrix == MyMatrix.new([[1,-2],[3,4],[15,6.0]]) ).to be true
			end
			it 'returns false if matrices are not equal' do
				expect( sample_matrix == MyMatrix.new([]) ).to be false
				expect( sample_matrix == MyMatrix.new([[1,-2],[3,4]]) ).to be false
				expect( sample_matrix == MyMatrix.new([[1,-2],[3,4],[15,6.1]]) ).to be false
				expect( sample_matrix == MyMatrix.new([[1,-2],[3,4],[15,7]]) ).to be false
			end
			it 'raises an error if argument is not a matrix' do
				the_error = ArgumentError, 'Matrix can be compared only with a matrix'
				expect{ sample_matrix == 1 }.to raise_error *the_error
				expect{ sample_matrix == 'string' }.to raise_error *the_error
				expect{ sample_matrix == [[1,-2],[3,4],[15,6]] }.to raise_error *the_error
			end
		end

		describe 'matrix + matrix' do
			it 'returns a new matrix' do
				expect( sample_matrix + sample_matrix ).to be_a MyMatrix
				expect( sample_matrix + sample_matrix ).not_to be sample_matrix
			end
			it 'returned matrix has elements equal to the sum of respective elements of the original matrices' do
				expect( (sample_matrix + sample_matrix).to_a ).to eq [[2, -4], [6, 8], [30, 12]]
			end
			it 'returned matrix and original have the same size' do
				expect( (sample_matrix + sample_matrix).size ).to eq sample_matrix.size
			end
			it 'works the same as the respective stdlib method' do
				m = Matrix[*sample_matrix.to_a]
				expect( (sample_matrix + sample_matrix).to_a ).to eq (m + m).to_a
			end
			it 'raises an error if argument is not a matrix' do
				the_error = ArgumentError, 'Matrix can be added only with a matrix'
				expect{ sample_matrix + 1 }.to raise_error *the_error
				expect{ sample_matrix + 'string' }.to raise_error *the_error
				expect{ sample_matrix + [[1,-2],[3,4]] }.to raise_error *the_error
			end
			it 'raises an error if matrices are not of the same size' do
				expect{ sample_matrix + MyMatrix.new([[1,-2],[3,4]]) }.to raise_error \
					ArgumentError, 'Matrices should be of the same size'
			end
		end

		describe 'matrix - matrix' do
			let :sample_matrix2 do
				MyMatrix.new [
					[ 1, 1],
					[ 1, 1],
					[ 1, 1]
				]
			end
			it 'returns a new matrix' do
				expect( sample_matrix - sample_matrix2 ).to be_a MyMatrix
			end
			it 'result elements equal to the subtraction of respective elements of the original matrices' do
				expect( (sample_matrix - sample_matrix).to_a ).to eq [[0, 0], [0, 0], [0, 0]]
				expect( (sample_matrix - sample_matrix2).to_a ).to eq [[0, -3], [2, 3], [14, 5]]
			end
			it 'works the same as the respective stdlib method' do
				m = Matrix[*sample_matrix.to_a]
				expect( (sample_matrix - sample_matrix).to_a ).to eq (m - m).to_a
				m2 = Matrix[*sample_matrix2.to_a]
				expect( (sample_matrix - sample_matrix2).to_a ).to eq (m - m2).to_a
			end
			it 'raises an error if argument is not a matrix' do
				the_error = ArgumentError, 'Matrix can be subtracted only with a matrix'
				expect{ sample_matrix - 1 }.to raise_error *the_error
				expect{ sample_matrix - 'string' }.to raise_error *the_error
				expect{ sample_matrix - [[1,-2],[3,4]] }.to raise_error *the_error
			end
			it 'raises an error if matrices are not of the same size' do
				expect{ sample_matrix - MyMatrix.new([[1,-2],[3,4]]) }.to raise_error \
					ArgumentError, 'Matrices should be of the same size'
			end
		end

		describe 'matrix * matrix' do
			let :sample_matrix2 do
				MyMatrix.new [
					[ 1, 1, 1],
					[ 1, 1, 1]
				]
			end
			it 'returns a new matrix' do
				expect( sample_matrix * sample_matrix2 ).to be_a MyMatrix
			end
			it 'result elements equal to the sum of multiplication of respective elements from rows and cols' do
				expect( sample_matrix * sample_matrix.transpose ).to eq MyMatrix.new [
					[  5,  -5,   3],
					[ -5,  25,  69],
					[  3,  69, 261]
				]
				expect( sample_matrix.transpose * sample_matrix ).to eq MyMatrix.new [
					[235, 100],
					[100,  56]
				]
				expect( sample_matrix * sample_matrix2 ).to eq MyMatrix.new [
					[-1, -1, -1],
					[ 7,  7,  7],
					[21, 21, 21]
				]
				expect( sample_matrix2 * sample_matrix ).to eq MyMatrix.new [
					[19, 8],
					[19, 8]
				]
				zero_matrix = MyMatrix.new [[0],[0]]
				expect( sample_matrix * zero_matrix ).to eq MyMatrix.new [[0], [0], [0]]
			end
			it 'works the same as the respective stdlib method' do
				m = Matrix[*sample_matrix.to_a]
				expect( (sample_matrix * sample_matrix.transpose).to_a ).to eq (m * m.transpose).to_a
				expect( (sample_matrix.transpose * sample_matrix).to_a ).to eq (m.transpose * m).to_a
				m2 = Matrix[*sample_matrix2.to_a]
				expect( (sample_matrix * sample_matrix2).to_a ).to eq (m * m2).to_a
				expect( (sample_matrix2 * sample_matrix).to_a ).to eq (m2 * m).to_a
			end
			it 'raises an error if argument is not a matrix or vector' do
				the_error = ArgumentError, 'Matrix can be multiplied only with a matrix or vector'
				expect{ sample_matrix * 1 }.to raise_error *the_error
				expect{ sample_matrix * 'string' }.to raise_error *the_error
				expect{ sample_matrix * [[1,-2],[3,4]] }.to raise_error *the_error
			end
			it 'raises an error if matrices are not conformable for multiplication' do
				expect{ sample_matrix * MyMatrix.new([[1,-2],[3,4],[5,6]]) }.to raise_error \
					ArgumentError, /Matrices should be conformable for multiplication/
			end
		end
		describe 'matrix * vector' do
			let :sample_vector do
				MyVector.new [1, 2]
			end
			it 'returns vector if multiplied by a vector' do
				expect( sample_matrix * sample_vector ).to be_a MyVector
				expect( sample_matrix * sample_vector ).to eq MyVector.new(-3, 11, 27)
				expect( sample_matrix * MyVector.new(0, 0) ).to eq MyVector.new(0, 0, 0)
			end
			it 'works the same as the respective stdlib method' do
				m = Matrix[*sample_matrix.to_a]
				v = Vector[*sample_vector.to_a]
				expect( (sample_matrix * sample_vector).to_a ).to eq (m * v).to_a
				expect( (sample_matrix * MyVector.new(0, 0)).to_a ).to eq (m * Vector[0,0]).to_a
			end
			it 'raises an error if matrix and vector are not conformable for multiplication' do
				the_error = ArgumentError, /Matrix and vector should be conformable/
				expect{ sample_matrix * MyVector.new(-3, 11, 27) }.to raise_error *the_error
				expect{ sample_matrix * MyVector.new(0) }.to raise_error *the_error
			end
		end

		describe 'matrix.transpose' do
			it 'returns a new matrix' do
				expect( sample_matrix.transpose ).to be_a MyMatrix
				expect( sample_matrix.transpose ).not_to be sample_matrix
			end
			it 'returned matrix has columns as rows in the original matrix' do
				expect( sample_matrix.transpose.cols ).to eq sample_matrix.rows
				expect( sample_matrix.transpose.to_a ).to eq [[1, 3, 15],[-2, 4, 6]]
			end
			it 'works the same as the respective stdlib method' do
				m = Matrix[*sample_matrix.to_a]
				expect( sample_matrix.transpose.to_a ).to eq m.transpose.to_a
			end
		end

		describe 'matrix.min_els' do
			it 'returns a structure with min element value and indexes where it was found' do
				expect( sample_matrix.min_els ).to eq(value:-2, indexes: [[0, 1]])
				expect( sample_matrix_with_multiple_min_max.min_els ).to eq(value:-2, indexes: [[0, 1], [1, 0]])
			end
		end
		describe 'matrix.max_els' do
			it 'returns a structure with max element value and indexes where it was found' do
				expect( sample_matrix.max_els ).to eq(value:15, indexes: [[2, 0]])
				expect( sample_matrix_with_multiple_min_max.max_els ).to eq(value:15, indexes: [[0, 0], [1, 1], [2, 0]])
			end
		end

		describe 'matrix.saddle_points' do
			it 'returns an array of saddle points data' do
				expect( sample_matrix.saddle_points ).to eq [
					{:value=>1, :position=>[0, 0]},
					{:value=>6, :position=>[2, 1]}
				]

				m = MyMatrix.new [
					[ 1, 3, 0],
					[ 2, 3, 0],
				]
				expect( m.saddle_points ).to eq [
					{:value=>3, :position=>[0, 1]},
					{:value=>0, :position=>[0, 2]},
					{:value=>3, :position=>[1, 1]},
					{:value=>0, :position=>[1, 2]}
				]

				m = MyMatrix.new [
					[ 1, 2, 3],
					[ 4, 5, 6],
					[ 7, 8, 9],
				]
				expect( m.saddle_points ).to eq [
					{:value=>3, :position=>[0, 2]},
					{:value=>7, :position=>[2, 0]}
				]

				m = MyMatrix.new [
					[ 1,  1,  2,  5,  6,  1],
					[ 5,  6,  8,  5,  6,  7],
					[10, 12, 10, 12, 11, 11],
					[ 8, 10,  5,  6,  8,  9],
					[ 6,  5, 10, 12, 15, 19]
				]
				expect( m.saddle_points ).to eq [
					{:value=>6,  :position=>[0, 4]},
					{:value=>10, :position=>[2, 0]},
					{:value=>10, :position=>[2, 2]}
				]
			end
			example 'there can be no saddle points' do
				expect( sample_matrix_with_multiple_min_max.saddle_points ).to eq []

				m = MyMatrix.new [
					[ 1, 2, 0],
					[ 4, 5, 6],
					[ 5, 1, 6],
				]
				expect( m.saddle_points ).to eq []
			end
			example 'edge case: when all elements are the same — no saddle points' do
				m = MyMatrix.new [
					[ 1, 1, 1],
					[ 1, 1, 1],
					[ 1, 1, 1],
				]
				expect( m.saddle_points ).to eq []
			end
		end

		describe 'matrix.norm(type)' do
			let :norm_sample_matrix do
				MyMatrix.new [
					[ 1,  2, -1,  5],
					[ 2,  4,  3,  2],
					[-1, -7,  3, 22]
				]
			end
			it 'returns Frobenius Norm of a matrix' do
				expect( sample_matrix.norm(:Frobenius).round(3) ).to eq 17.059
				expect( norm_sample_matrix.norm(:Frobenius).round(3) ).to eq 24.637
			end
			it 'returns Infinity Norm of a matrix' do
				expect( sample_matrix.norm :infinity ).to eq 21
				expect( norm_sample_matrix.norm :infinity ).to eq 33
			end
			it 'returns 1-Norm of a matrix' do
				expect( sample_matrix.norm :one ).to eq 19
				expect( norm_sample_matrix.norm :one ).to eq 29
			end
			it 'raises an error if the type is not provided' do
				expect{ sample_matrix.norm }.to raise_error ArgumentError, /wrong number of arguments/
			end
			it 'raises an error if the type is not supported' do
				expect{ sample_matrix.norm :unsupported_type }.to raise_error ArgumentError, 'Type should be :Frobenius, :infinity or :one'
			end
		end
	end

	describe 'helper methods' do
		describe 'matrix.cols' do
			it 'returns an array of columns' do
				expect( sample_matrix.cols ).to eq [[1, 3, 15], [-2, 4, 6]]
			end
		end
		describe '-matrix' do
			it 'returns a new matrix with all elements negated' do
				expect( -sample_matrix ).to eq MyMatrix.new [[-1, 2], [-3, -4], [-15, -6]]
			end
		end
		describe 'matrix.map {...}' do
			it 'returns new matrix that is the result of iteration of the block over all elements' do
				expect( sample_matrix.map {|el| el*2 } ).to eq MyMatrix.new [[2, -4], [6, 8], [30, 12]]
			end
		end
		describe 'matrix.to_a' do
			it 'returns all matrix elements as an array of rows' do
				expect( sample_matrix.to_a ).to eq [[1, -2], [3, 4], [15, 6]]
			end
		end
		describe 'matrix.to_s' do
			it 'prints the matrix in a nice aligned multiline form' do
				expect( sample_matrix.to_s ).to eq <<~END
					MyMatrix 3 × 2:
					  1 -2
					  3  4
					 15  6
				END
				expect( sample_matrix.to_s ).to eq "MyMatrix 3 × 2:\n  1 -2\n  3  4\n 15  6\n"
			end
		end
	end

end


RSpec.configure do |config|
	config.filter_run :focus
	config.run_all_when_everything_filtered = true
	config.formatter = :documentation
end
