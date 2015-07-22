require 'i3ipc/protocol'
require 'i3ipc/reply'

module I3Ipc
  # Throws when subscribing to an invalid event. Valid events are
  # listed in function event_number().
  class WrongEvent < RuntimeError
    def initialize(event_name)
      @event_name = event_name
    end

    def message
      %Q{Tried to subscribe to invalid event type '#{@event_name}'}
    end
  end

  # Entry point for communication with i3-ipc.
  # Able to send/receive messages and convert
  # responses.
  #
  # @example
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

    def subscribe(event, block)
      event_number = event_number(event)

      # Send subscription request
      @protocol.send(2, [event])

      reply = Reply.parse(@protocol.receive 2)
      raise WrongEvent.new(event) unless reply.success?

      pid = Thread.new do
        while true
          reply = Reply.parse(@protocol.receive_event event_number)
          block.call(reply)
        end
      end

      pid
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

    private

    def reply_for(type, message = nil, events=nil)
      @protocol.send(type, message)

      Reply.parse(@protocol.receive type)
    end

    def event_number(event)
      case event
      when 'workspace'         then 0
      when 'output'            then 1
      when 'mode'              then 2
      when 'window'            then 3
      when 'barconfig_update'  then 4
      when 'binding'           then 5
      else raise WrongEvent.new(event)
      end
    end

  end
end
