class MatchData

  # Ruby global variables $1..$9 implemented by MatchData(C)>>nthRegexRef:

  primitive 'at', 'at:'
  primitive_nobridge '[]' , '_rubyAt:'

  primitive '[]' , '_rubyAt:length:'  # result is an Array

  primitive_nobridge '__at' , '_rubyAt:'
  primitive '__at' , '_rubyAt:length:'

  def inspect
    matches = self.__at(0, -1)
    "MatchData: #{matches.inspect}"
  end

  def begin(group)
    self.at((group*2)+1)
  end


  def captures   	# from Rubinius
    self.__at(1, self.size - 1)
  end

  def collapsing?	# from Rubinius
    self.begin(0) == self.end(0)
  end

  def end(group)
    self.at((group*2)+2)
  end

  primitive '__size', 'size'
  def size
    self.__size.__divide(2)
  end

  alias length size

  def pre_match  	# from Rubinius
    # public, and also invoked from generated code for RubyBackRefNode
    res = @strPreceedingMatch
    if (res._equal?(nil))
      res = @inputString[0, self.begin(0)]
      @strPreceedingMatch = res
    end
    res
  end

  def post_match
    # public, and also invoked from generated code for RubyBackRefNode
    res = @strFollowingMatch
    if (res._equal?(nil))
      res = @inputString[self.end(0)..-1]
      @strFollowingMatch = res
    end
    res
  end

  def __plus_match
    # invoked from generated code for RubyBackRefNode
    self[ self.length - 1 ]
  end

  def string
    @inputString
  end


  def offset(n)
    [self.begin(n), self.end(n)]
  end

  def pre_match_from(idx)	# from Rubinius
    beg_zero = self.begin(0)
    return "" if beg_zero._equal?(0) # maglev
    pre_end = beg_zero - 1
    @inputString[idx, pre_end-idx+1]
  end

  def select(&block)
    result = []
    i = 0
    lim = self.size
    while i < lim
      elem = self[i]
      result << elem if block.call( elem )
      i += 1
    end
    result
  end

  def to_a
    self.__at(0, self.size )
  end

  def to_s
    self[0]
  end

  def values_at(*indicies)
    result = []
    i = 0
    lim = indicies.length
    while i < lim
      result << self[indicies[i]]
      i += 1
    end
    result
  end

end

