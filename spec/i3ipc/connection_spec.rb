require 'spec_helper'

module I3Ipc
  describe Connection do
    before(:each) do
      allow_any_instance_of(Protocol).to receive(:connect)
        .and_return(:connected)

      allow_any_instance_of(Protocol).to receive(:disconnect)
        .and_return(:disconnected)

      allow_any_instance_of(Protocol).to receive(:send)
        .and_return(:sent)

      allow_any_instance_of(Protocol).to receive(:receive)
        .and_return(%Q[{"success": true}])
    end

    describe '#reply_for' do
      it 'sends and receives message from i3' do
        connection = Connection.new
        reply = connection.reply_for(0, 'my command')
        expect(reply.success).to be true
      end
    end
  end
end
