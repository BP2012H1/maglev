# -*- encoding: us-ascii -*-

class Array
  # Creates a new Array from the return values of passing
  # each element in self to the supplied block.
  primitive_nobridge 'map&' , 'collect:'

  def self.coerce_into_array(obj)
    return [obj] unless obj

    return obj.to_a   if obj.respond_to?(:to_a)
    return obj.to_ary if obj.respond_to?(:to_ary)

    # On 1.9, #to_a is not defined on all objects, so wrap the object in a
    # literal array.
    return [obj]
  end
end
