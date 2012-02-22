# -*- encoding: us-ascii -*-

class Thread
  class << self
    alias_method :fork, :start
  end

  def self.stop
    sleep
    nil
  end
end
