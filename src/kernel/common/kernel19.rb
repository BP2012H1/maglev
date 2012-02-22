# -*- encoding: us-ascii -*-

module Kernel
  alias_method :equal?, :eql?
  alias_method :==,   :equal?
  alias_method :===,  :equal?

  define_method "!~" do |other|
    self =~ other ? false : true
  end

  def trust
    @__trust = true
    self
  end

  def untrust
    @__trust = false
  end

  def untrusted?
    !!@__trust
  end
end
