require 'socket'
require 'fileutils'

module I3Ipc
  # Simple socket server that communicates with
  # client simulating i3-ipc messages.
  class I3MockServer
    SOCKET_PATH = '/tmp/i3-mock-server.sock'

    def initialize
      remove_sock
      @server = UNIXServer.new(SOCKET_PATH)
    end

    def accept_client
      @client = @server.accept_nonblock
      self
    rescue IO::WaitReadable, Errno::EINTR
      nil
    end

    def client_alive?
      return false unless @client
      @client.write 'hi'
      true
    rescue Errno::EPIPE
      false
    end

    def receive(len)
      raise 'Client not accepted yet' unless @client
      @client.read(len)
    end

    def send(data)
      raise 'Client not accepted yet' unless @client
      @client.write(data)
    end

    def close_client
      @client.close if @client
      @client = nil
    end

    def close
      close_client
      @server.close unless @server.closed?
      remove_sock
    end

    private

    def remove_sock
      FileUtils.rm(SOCKET_PATH) if File.exist?(SOCKET_PATH)
    end
  end
end
