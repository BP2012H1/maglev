class Env
    # A ruby reference to ENV that resolves to ::ENV results in access
    # to a  transient Ruby constant , whose value is
    # the one transient instance of Env , stored in  SessionTemps current .

    class_primitive_nobridge '__getenv', '_getenv:'
    class_primitive_nobridge '__putenv', '_putenv:with:'
    class_primitive_nobridge '__unsetenv', '_unsetenv:'

    def self.new
      raise NotImplementedError, "Env.new"
    end

    def self.[](*elements)
      raise NotImplementedError, "Env.[]"
    end

    def dup
      res = Hash.new
      res.update(self)
      res
    end

    def clone
      self.dup
    end

    def [](key)
      v = __atkey(key)
      if v._equal?(nil)
        v = Env.__getenv(key)
        unless v._equal?(nil)
          self.__atkey_put( key, v ) # __atkey_put implemented in Hash
        end
      end
      v
    end

    def _update_ok(key)
      unless key._isString
        return false
      end
      if key.index('GEMSTONE')._equal?(0) ||
         (key.index('MAGLEV')._equal?(0) and key != 'MAGLEV_OPTS')
        return false
      end
      return true
    end
     

    def __check_update(key)
      if key._isString
        unless _update_ok(key)
          raise "you may not change #{key} environment variable from within maglev"
        end
      end
    end

    def []=(key, val)
      self.__check_update(key)
      if val._equal?(nil)
        Env.__unsetenv(key)
        self.__delete(key)
      else
        Env.__putenv(key, val)
        self.__atkey_put(key, val) # __atkey_put implemented in Hash 
      end
    end

    def store(key, val)
     self.[]=(key, val)
    end

    def clear    # not allowed by Maglev
      raise NotImplementedError, "Env#clear"
    end

    def delete(key, &block)
      self.__check_update(key)
      v = self.__delete(key)
      if v._not_equal?(RemoteNil)
        Env.__unsetenv(key)
        return v
      elsif block_given?
        return block.call(key)
      else
        return nil
      end
    end

    def delete_if(&block)
      arr = []
      self.each_pair { | key , v |
         if block.call(key, v) && self._update_ok(key)
           arr.__push( key )
         end
      }
      arr.each { |key|
         v = self.__delete(key)
         if v._not_equal?(RemoteNil)
           Env.__unsetenv(key)
         end
      } 
      self
    end

    def merge(aHash)
      raise NotImplementedError, "Env#merge"
    end
    def merge!(other)
      raise NotImplementedError, "Env#merge!"
    end

    def to_s
      "ENV"
    end
end

