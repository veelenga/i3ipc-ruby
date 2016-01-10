require 'json'

module I3Ipc
  # Wrapper for reply from i3-ipc.
  #
  # Able to parse Numeric, String, TrueClass, FalseClass,
  # Array, Hash from passed string in json format.
  #
  # @example
  #  response = Reply.parse(
  #   %Q{
  #      {
  #       "name": "LVDS1",
  #       "active": true,
  #       "current_workspace": "4",
  #       "rect": {
  #        "x": 0,
  #        "y": 0,
  #        "width": 1280,
  #        "height": 800
  #       }
  #      }
  #    }
  #  )
  #
  #  p response.name        # => "LVDS1"
  #  p response.active      # => true
  #  p response.rect.width  # => 1280
  #  # ...
  #
  #  response = Reply.parse(%Q{ {"data": [{"key1": true}, {"key2": false}]} })
  #  p response.data[0].key1 # => true
  #  p response.data[0].key2 # => false
  class Reply
    def initialize(data)
      @data = data.dup
    end

    # Parses response from I3-ipc protocol.
    #
    # @param [String] response response from i3 in json format.
    #
    # @return [Reply] object with dynamically accessed values.
    def self.parse(response)
      parse_data JSON.parse(response)
    end

    # Indicates whether this reply is successful or not.
    #
    # @return false if this reply represents and error from i3-ipc protocol.
    #   Otherwise returns true, which means that request is successful and
    #   reply has some data.
    def success?
      not self.respond_to? :error
    end

    def method_missing(name, *args, &block)
      if @data.include?(name)
        raise ArgumentError.new('wrong number of arguments (%d for 0)' % args.length) if args.length > 0
        return @data[name]
      else
        super
      end
    end

    def respond_to?(method_sym, include_private = false)
      if @data.include?(method_sym)
        true
      else
        super
      end
    end

    def to_s
      JSON.pretty_generate(to_h)
    end

    def to_h
      data = @data.dup
      data.each do |k, v|
        data[k] = Reply.unparse_data v
      end
    end

    private

    def self.parse_data(data)
      case data
      when Numeric, String, TrueClass, FalseClass, NilClass
        return data
      when Array
        return data.map {|v| parse_data(v)}
      when Hash
        data.each do |k, v|
          data[k] = parse_data v
        end
        return Reply.new(Hash[data.map {|k, v| [k.to_sym, v]}])
      else
        raise "Unable to parse data of type #{data.class}"
      end
    end

    def self.unparse_data(data)
      case data
      when Numeric, String, TrueClass, FalseClass, NilClass
        data
      when Reply
        data.to_h
      when Array
        data.map! {|x| self.unparse_data(x)}
        data
      end
    end
  end
end
