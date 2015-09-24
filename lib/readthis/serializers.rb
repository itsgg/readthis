require 'json'
require 'readthis/passthrough'

module Readthis
  SerializersFrozenError = Class.new(StandardError)
  SerializersLimitError  = Class.new(StandardError)
  UnknownSerializerError = Class.new(StandardError)

  class Serializers
    BASE_SERIALIZERS = {
      Marshal     => 0x1,
      Passthrough => 0x2,
      JSON        => 0x3
    }.freeze

    SERIALIZER_LIMIT = 7

    attr_reader :serializers, :inverted

    # Creates a new Readthis::Serializers entity. No configuration is expected
    # during initialization.
    #
    def initialize
      reset!
    end

    # Append a new serializer. Up to 7 total serializers may be configured for
    # any single application be configured for any single application. This
    # limit is based on the number of bytes available in the option flag.
    #
    # @param [Module] Any object that responds to `dump` and `load`
    # @return [self] Returns itself for possible chaining
    #
    # @example
    #
    #     serializers = Readthis::Serializers.new
    #     serializers << Oj
    #
    def <<(serializer)
      case
      when serializers.frozen?
        fail SerializersFrozenError
      when serializers.length > SERIALIZER_LIMIT
        fail SerializersLimitError
      else
        @serializers[serializer] = flags.max.succ
        @inverted = @serializers.invert
      end

      self
    end

    # Freeze the serializers hash, preventing modification.
    #
    def freeze!
      serializers.freeze
    end

    # Reset the instance back to the default state. Useful for cleanup during
    # testing.
    #
    def reset!
      @serializers = BASE_SERIALIZERS.dup
      @inverted = @serializers.invert
    end

    # Find a flag for a serializer object.
    #
    # @param [Object] Look up a flag by object
    # @return [Number] Corresponding flag for the serializer object
    #
    # @example
    #
    #   serializers.assoc(JSON) #=> 1
    #
    def assoc(serializer)
      flag = serializers[serializer]

      unless flag
        fail UnknownSerializerError, "'#{serializer}' hasn't been configured"
      end

      flag
    end

    # Find a serializer object by flag value.
    #
    # @param [Number] Flag to look up the serializer object by
    # @return [Module] The serializer object
    #
    def rassoc(flag)
      serializer = inverted[flag]

      unless serializer
        fail UnknownSerializerError, "'#{flag}' doesn't match any serializers"
      end

      serializer
    end

    private

    def flags
      serializers.values
    end
  end
end