require 'i3ipc/protocol'
require 'i3ipc/reply'

module I3Ipc
  # Entry point for communication with i3-ipc.
  # Able to send/receive messages and convert
  # responses.
  #
  # Usage example:
  #   con = Connection.new
  #   p con.version.human_readable         # => 4.10.2 (2015-0...
  #   p con.command('focus left').success? # => true
  #   p con.workspaces[0].name             # => 0 Term
  #   # ...
  #   con.close
  class Connection

    def initialize(connect = true)
      @protocol = Protocol.new
      connect && @protocol.connect
    end

    def connect
      @protocol.connect
    end

    def disconnect
      @protocol.disconnect
    end

    def command(cmds)
      reply_for(0, cmds)
    end

    def workspaces
      reply_for(1)
    end

    def outputs
      reply_for(3)
    end

    def tree
      reply_for(4)
    end

    def marks
      reply_for(5)
    end

    def bar_config
      reply_for(6)
    end

    def version
      reply_for(7)
    end

    def reply_for(type, message = nil)
      @protocol.send(type, message)
      Reply.parse(@protocol.receive type)
    end
  end
end
