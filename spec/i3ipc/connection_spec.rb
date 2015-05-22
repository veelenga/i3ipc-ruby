require 'spec_helper'

module I3Ipc
  describe Connection do

    describe '#command' do

      before(:all) do
        class Connection
          def initialize
            @protocol = Protocol.new ''
          end
        end
      end

      it 'returns Reply object' do
        allow_any_instance_of(Protocol).to receive(:send)
        allow_any_instance_of(Protocol).to receive(:receive)
          .and_return("{}")

        expect(Connection.new.command('cmd')).to be_a Reply
      end

      it 'sends correct command and receives success response' do
        allow_any_instance_of(Protocol).to receive(:send)
        allow_any_instance_of(Protocol).to receive(:receive)
          .and_return(%Q[{"success": true}])

        connection = Connection.new
        reply = connection.command('focus left')
        expect(reply.success).to be true
      end

      it 'sends incorrect command and receives error response' do
        allow_any_instance_of(Protocol).to receive(:send)
        allow_any_instance_of(Protocol).to receive(:receive)
          .and_return(%Q[{"success": false, "error": "wrong command"}])

        connection = Connection.new
        reply = connection.command('my command')
        expect(reply.success).to be false
        expect(reply.error).to eql 'wrong command'
      end
    end
  end
end
