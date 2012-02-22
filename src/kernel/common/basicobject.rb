# -*- encoding: us-ascii -*-

class BasicObject
  primitive_nobridge :equal?, :"="
  primitive_nobridge :==, :"="
  primitive_nobridge :"!=", :"~="
end
