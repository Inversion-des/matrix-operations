class MyVector < Array

	def initialize(*array)
		array.flatten!(1) # to be able to pass an array or just a list of numbers
		raise ArgumentError, 'All the elements should be numeric' if !array.all?{|el| el.is_a?(Numeric) }
		super array
	end

	def scalar_product(other_vector)
		raise ArgumentError, 'Vector can be multiplied only with a vector' unless other_vector.is_a?(self.class)
		raise ArgumentError, 'Vectors should be of the same size' if other_vector.size != size

		# sum of products of respective elements of two vectors
		zip(other_vector).sum {|el1, el2| el1*el2 }
	end

end