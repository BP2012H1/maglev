# file marshal2.rb

# the constants Marshal__* are defined in Object in marshal.rb,
# so they can be resolved at compile time in this file,
# and replicate values of the respective Marshal:: constants

class Object
  def to_marshal(ms, strip_ivars = false)
    out = ms.serialize_extended_object(self)
    out << Marshal__TYPE_OBJECT
    out << ms.serialize(self.class.name.to_sym)
    #out << ms.serialize_instance_variables_suffix(self, true, strip_ivars)
    out << ms.serialize_instance_variables_suffix(self, self.instance_variables)
    out
  end
end

class Range
  def to_marshal(ms)
    out = ms.serialize_extended_object(self)
    out << Marshal__TYPE_OBJECT
    out << ms.serialize(self.class.name.to_sym)
    out << ms.serialize_ivars( [ :begin , self.begin,
                                 :end , self.end,
                                 :excl , self.exclude_end? ])
    out
  end
  def from_marshal(ivar, value)
    if ivar._equal?(:begin)
      @from = value
    elsif ivar._equal?( :end)
      @to = value
    elsif ivar._equal?( :excl)
      @excludeEnd = value
    else
      raise TypeError, 'unrecognized instvar in Range#from_marshal'
    end
  end
end

class NilClass
  def to_marshal(ms)
    Marshal__TYPE_NIL
  end
end

class Boolean
  def to_marshal(ms)
    self._equal?(true) ? Marshal__TYPE_TRUE : Marshal__TYPE_FALSE
  end
end

class Class
  def to_marshal(ms)
    raise TypeError, "can't dump anonymous class #{self}" if self.name == ''
    Marshal__TYPE_CLASS + ms.serialize_integer(name.length) + name
  end
end

class Module
  def to_marshal(ms)
    raise TypeError, "can't dump anonymous module #{self}" if self.name == ''
    Marshal__TYPE_MODULE + ms.serialize_integer(name.length) + name
  end
end

class Symbol
  def to_marshal(ms)
    # caller responsible for find_symlink (i.e. lookup in syms_dict )
    str = to_s
    Marshal__TYPE_SYMBOL + ms.serialize_integer(str.length) + str
  end
end

class String
  def to_marshal(ms)
    ivars = [ nil]
    out = ms.serialize_instance_variables_prefix(self, ivars)
    out << ms.serialize_extended_object(self)
    out << ms.serialize_user_class(self, String)
    out << Marshal__TYPE_STRING
    out << ms.serialize_integer(self.length) << self
    out << ms.serialize_instance_variables_suffix(self, ivars[0])
  end
end

class Fixnum
  def to_marshal(ms)
    Marshal__TYPE_FIXNUM + ms.serialize_integer(self)
  end
end

class Bignum
  def to_marshal(ms)
    str = Marshal__TYPE_BIGNUM + (self < 0 ? '-' : '+')
    cnt = 0
    num = self.abs

    while num != 0
      str << ms.to_byte(num)
      num >>= 8
      cnt += 1
    end

    if cnt % 2 == 1
      str << "\0"
      cnt += 1
    end

    str[0..1] + ms.serialize_integer(cnt.__divide(2) ) + str[2..-1]
  end
end

class Regexp
  def to_marshal(ms)
    str = self.source
    ivars = [ nil]
    out = ms.serialize_instance_variables_prefix(self, ivars)
    out << ms.serialize_extended_object(self)
    out << ms.serialize_user_class(self, Regexp)
    out << Marshal__TYPE_REGEXP
    out << ms.serialize_integer(str.length) + str
    out << ms.to_byte(options & 0x7)
    out << ms.serialize_instance_variables_suffix(self, ivars[0])
  end
end

class Struct
  def to_marshal(ms)
    ivars = [ nil]
    out =  ms.serialize_instance_variables_prefix(self, ivars)
    out << ms.serialize_extended_object(self)

    out << Marshal__TYPE_STRUCT

    out << ms.serialize(self.class.name.to_sym)
    out << ms.serialize_integer(self.length)

    self.each_pair do |name, value|
      out << ms.serialize(name)
      out << ms.serialize(value)
    end

    out << ms.serialize_instance_variables_suffix(self, ivars[0])
    out
  end
end

class Array
  def to_marshal(ms)
    ivars = [ nil]
    out = ms.serialize_instance_variables_prefix(self, ivars)
    out << ms.serialize_extended_object(self)
    out << ms.serialize_user_class(self, Array)
    out << Marshal__TYPE_ARRAY
    out << ms.serialize_integer(self.length)
    # Gemstone, optimization to use while loop
    n = 0
    lim = self.length
    while n < lim
      out << ms.serialize(self[n])
      n = n + 1
    end   # end Gemstone
    out << ms.serialize_instance_variables_suffix(self, ivars[0])
  end
end

class Hash
  def to_marshal(ms)
    raise TypeError, "can't dump hash with default proc" if default_proc

    #  excluded_ivars = %w[@bins @count @records]  # Rubinius only
    ivars = [ nil]
    out = ms.serialize_instance_variables_prefix(self, ivars)
    out << ms.serialize_extended_object(self)
    out << ms.serialize_user_class(self, Hash)
    default_val = self.default
    out << (default_val ? Marshal__TYPE_HASH_DEF : Marshal__TYPE_HASH)
    len = self.length
    out << ms.serialize_integer(len)
    unless len._equal?(0) then
      each_pair do |(key, val)|
        out << ms.serialize(key)
        out << ms.serialize(val)
      end
    end
    out << (default_val ? ms.serialize(default_val) : '')
    out << ms.serialize_instance_variables_suffix(self, ivars[0])
    out
  end
end

class Float
  def to_marshal(ms)
    if finite?
      if self == 0.0
        str = self.__sign < 0 ? '-0' : '0'
      else
        str = "%.17g" % [self] + ms.serialize_float_thing(self)
      end
    elsif nan? then
      str = "nan"
    elsif infinite? then
      str = self < 0 ? "-inf" : "inf"
    else
      raise 'logic error in Float.to_marshal'
    end
    Marshal__TYPE_FLOAT + ms.serialize_integer(str.length) + str
  end
end
