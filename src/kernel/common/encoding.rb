# -*- encoding: us-ascii -*-

class EncodingError < StandardError
end

class Encoding
  attr_reader :name
  def initialize(name)
    @name = name
  end
  private :initialize

  class UndefinedConversionError < EncodingError
  end

  class CompatibilityError < EncodingError
  end

  # FIXME: Just stubbing right now
  EncodingMap   = {
    "UTF-8" => [nil, 1],
    "LOCALE" => ["locale", 1],
    "EXTERNAL" => ["external", 1],
    "FILESYSTEM" => ["filesystem", 1],
    "ASCII-8BIT" => [nil, 0],
    "ISO8859-1" => [nil, 0] }
  LocaleCharmap = "UTF-8"

  class Transcoder
    attr_accessor :source
    attr_accessor :target

    def inspect
      "#<#{super} #{source} to #{target}"
    end
  end

  class Converter
    def initialize(from, to, options={})
    end

    def convert(str)
    end
  end

  def self.aliases
    aliases = {}
    EncodingMap.each do |n, r|
      index = r.last
      next unless index

      aname = r.first
      aliases[aname] = EncodingList[index].name if aname
    end

    aliases
  end

  def self.set_alias_index(name, obj)
    key = name.upcase.to_sym

    case obj
    when Encoding
      source_name = obj.name
    when nil
      EncodingMap[key][1] = nil
      return
    else
      source_name = StringValue(obj)
    end

    entry = EncodingMap[source_name.upcase.to_sym]
    raise ArgumentError, "unknown encoding name - #{source_name}" unless entry
    index = entry.last

    EncodingMap[key][1] = index
  end
  private_class_method :set_alias_index

  def self.default_external
    find "external"
  end

  def self.default_external=(enc)
    raise ArgumentError, "default external encoding cannot be nil" if enc.nil?

    set_alias_index "external", enc
    set_alias_index "filesystem", enc
  end

  def self.default_internal
    find "internal"
  end

  def self.default_internal=(enc)
    set_alias_index "internal", enc
  end

  def self.find(name)
    key = StringValue(name).upcase

    EncodingMap.each do |n, r|
      if n.to_s.upcase == key
        index = r.last
        return index && EncodingList[index]
      end
    end

    raise ArgumentError, "unknown encoding name - #{name}"
  end

  def self.list
    EncodingList
  end

  def self.locale_charmap
    LocaleCharmap
  end

  def self.name_list
    EncodingMap.map do |n, r|
      index = r.last
      r.first or (index and EncodingList[index].name)
    end
  end

  def inspect
    "#<Encoding:#{name}(dummy)>"
  end

  def names
    entry = EncodingMap[name.upcase.to_sym]
    names = [name]
    EncodingMap.each do |k, r|
      aname = r.first
      names << aname if aname and r.last == entry.last
    end
    names
  end

  def _dump(depth)
    name
  end

  def self._load(name)
    find name
  end
end

Encoding::EncodingList = [Encoding.new("ASCII-8BIT"), Encoding.new("UTF-8")]
Encoding.__freeze_constants

# TODO: This psuedo variable should represent a scripts encoding.
Object.send :define_method, :__ENCODING__ do
  Encoding.new
end
