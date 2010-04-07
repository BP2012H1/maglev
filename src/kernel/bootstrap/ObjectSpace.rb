module ObjectSpace
  class System 
    class_primitive_nobridge '__session_state', '_sessionStateAt:'
  end

  class Finalizer  # identically smalltalk RubyFinalizer

    # Finalizers are not useable during bootstrap.

    # uses IdentityHash stored in System.__session_state(19),
    #  which is created by GsProcess(C)>>initRubyMainThread:env:
    #  keys are objectIds of objects having finalizers,
    #  values are instances of Finalizer.

    class_primitive_nobridge '__new', 'new:proc:'
    primitive_nobridge       '__add', 'addProc:'

    def __finalize(proc, obj)
      # invoked from Smalltalk
      proc.call(obj)
      nil
    end

    def __finalize_done(dict)
      oid = @_st_obj.__id
      @_st_obj = nil
      @_st_procs = nil
      dict.__delete(oid)
      nil
    end

    def __finalize_done
      # invoked from Smalltalk
      dict = System.__session_state(19)
      self.__finalize_done(dict)
      nil
    end

    def self.__create(obj, proc)
      dict = System.__session_state(19)
      oid =  obj.__id
      finalizer = dict.__atkey(oid)
      if finalizer._equal?(nil)
        finalizer = self.__new(obj, proc)
        dict.__atkey_put(oid, finalizer)
      else
        finalizer.__add(proc)
      end 
      nil
    end

    def self.__remove(obj)
      dict = System.__session_state(19)
      oid =  obj.__id
      finalizer = dict.__atkey(oid)
      if finalizer._not_equal?(nil) 
        finalizer.__finalize_done(dict)
      end
      nil
    end
  end

  def _id2ref(object_id)
    System.__object_for_oop(object_id)
  end

  # define_finalizer causes a_proc to be invoked with obj as the first arg
  # when obj is about to be  garbage collected.
  # It is implemented using Smalltalk ephemerons ; see class RubyFinalizer .
  # If a_proc was created at the top level of a Ruby main program, or
  # within a method that does an eval , the argument to the Proc may get written
  # to the home context of that method, thus preventing obj from being garbage
  # collected as expected after the proc is run .
  #
  def define_finalizer(obj, a_proc)
    # Smalltalk code raises ArgumentError if obj is a committed object .
    unless a_proc._kind_of?(Proc) || a_proc._isExecBlock || a_proc.respond_to?( :call )
      raise TypeError, 'define_finalizer expected a Block or Proc'
    end 
    Finalizer.__create(obj, a_proc) 
    self
  end

  def define_finalizer(obj)
    raise ArgumentError, 'define_finalizer called without a Proc'
  end

  def define_finalizer(obj, &block) # Maglev extension
    # raises ArgumentError if obj is a committed object .
    unless block._isExecBlock || a_proc._kind_of?(Proc) 
      raise TypeError, 'define_finalizer expected a Block or Proc'
    end
    Finalizer.__create(obj, block) 
    self
  end

  def each_object(class_or_module=nil, &block)
    raise NotImplementedError, ' each_object not implemented'
  end

  def garbage_collect()
    # has no effect in Maglev
    return nil
  end

  def undefine_finalizer(obj)
    Finalizer.__remove(obj)
    nil
  end

  module_function :_id2ref, :define_finalizer, :each_object, :garbage_collect, :undefine_finalizer
end
