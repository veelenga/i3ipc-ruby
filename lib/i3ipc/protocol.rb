require 'socket'

module I3Ipc
  # Communication interface with i3-ipc.
  #
  # Can connect to i3-ipc socket, disconnect, send and receive messages.
  #
  # Usage example:
  #   protocol = Protocol.new
  #   protocol.send(7)
  #   puts protocol.receive
  #   protocol.disconnect
  #
  # For i3-ipc interface details refer to https://i3wm.org/docs/ipc.html.
  class Protocol
    # Magic string for i3-ipc protocol to ensure the integrity of messages.
    MAGIC_STRING = 'i3-ipc'

    # Throws when received data with not expected magic string.
    # Usually this means that protocol is not compatible with
    # current i3-ipc version.
    class WrongMagicString < RuntimeError
      def initialize(magic_string)
        @magic_string = magic_string
      end

      def message
        %Q{Magic code expected '#{MAGIC_STRING}', but was '#{@magic_string}'}
      end
    end

    # Throws when received data with not expected type.
    class WrongType < RuntimeError
      def initialize(expected, actual)
        @expected = expected
        @actual = actual
      end

      def message
        %Q{Message type expected '#{@expected}', but was '#{@actual}'}
      end
    end

    # Throws when protocol trying to do some action
    # on non-connected channel.
    class NotConnected < RuntimeError; end

    def initialize(socketpath = nil)
      @socketpath = socketpath ? socketpath : get_socketpath
    end

    # Connects to i3-ipc server socket using Socket::UNIXSocket.
    # Does nothing if already connected.
    def connect
      @socket = UNIXSocket.new(@socketpath) unless @socket
    end

    # Disconnects from i3-ipc server socket.
    # Does nothing if not connected.
    def disconnect
      @socket && @socket.close
      @socket = nil
    end

    # Sends packed message to i3-ipc server socket.
    #
    # Throws:
    # * NotConnected if protocol is not connected.
    #
    # +type+: type of the message.
    # +payload+: payload of the message
    def send(type, payload = nil)
      check_connected
      @socket.write(pack(type, payload))
    end

    # Receives message from i3-ipc server socket.
    #
    # Throws:
    # * NotConnected if protocol is not connected.
    # * WrongMagicString if got message with not expected magic string.
    # * WrongType if got message with not expected magic type.
    #
    # +type+: expected type of the message.
    def receive(type = nil)
      check_connected
      # length of "i3-ipc" + 4 bytes length + 4 bytes type
      data = @socket.read 14
      magic, len, recv_type = unpack_header(data)

      raise WrongMagicString.new(magic) unless MAGIC_STRING.eql? magic
      type && (raise WrongType.new(type, recv_type) unless type == recv_type)

      @socket.read(len)
    end

    private

    # Packs the message.
    # A typical message looks like:
    #   <header><payload>
    # where a header is:
    #   <magic string><message length><message type>
    #
    # +type+: type of the message
    # +payload+: patload of the message
    def pack(type, payload=nil)
      size = payload ? payload.to_s.bytes.count : 0
      msg = MAGIC_STRING + [size, type].pack("LL")
      msg << payload.to_s if payload
      msg
    end

    # Unpacks the header.
    # A typical header looks like:
    #   <magic_string><message length><message type>
    #
    # +data+: data to be unpacked.
    def unpack_header(data)
      struct_header_len = MAGIC_STRING.size
      magic_message = data[0, struct_header_len]
      len, type = data[struct_header_len..-1].unpack("LL")
      [magic_message, len, type]
    end

    def get_socketpath
      path = `i3 --get-socketpath`.chomp!
      raise 'Unable to get i3 socketpath' unless path
      path
    end

    def check_connected
      raise NotConnected unless @socket
    end
  end
end