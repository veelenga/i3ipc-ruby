require 'spec_helper'

module I3Ipc
  describe Protocol do

    before(:all) do
      # open internal methods for verification needs
      class Protocol
        public :pack, :unpack_header
      end
    end

    before(:each, :i3 => :simulate) do
      @i3_srv = I3MockServer.new
      subject.connect
      @i3_srv.accept_client
    end

    after(:each, :i3 => :simulate) do
      @i3_srv.close
      subject.disconnect
    end

    subject { Protocol.new(I3MockServer::SOCKET_PATH) }

    it 'has MAGIC_STRING string constant' do
      expect(Protocol::MAGIC_STRING).to be_a String
    end

    describe '#connect' do
      it 'fails to connect if server not running' do
        expect { subject.connect }.to raise_error Errno::ENOENT
      end

      it 'connects if server running', :i3 => :simulate do
        expect(@i3_srv.client_alive?).to be true
      end

      it 'reconnects if disconnected', :i3 => :simulate do
        subject.disconnect
        subject.connect
        expect(@i3_srv.accept_client.client_alive?).to be true
      end

      it 'does nothing if already connected', :i3 => :simulate do
        subject.connect
        expect(@i3_srv.accept_client).to be nil
        expect(@i3_srv.client_alive?).to be true
      end
    end

    describe '#disconnect', :i3 => :simulate do
      it 'disconnects if connected' do
        subject.disconnect
        expect(@i3_srv.client_alive?).to be false
      end

      it 'does nothing if aready disconnected' do
        subject.disconnect
        subject.disconnect
        expect(@i3_srv.client_alive?).to be false
      end
    end

    describe '#send', :i3 => :simulate do
      let(:type) { 42 }
      let(:message) { 'test_send' }

      it 'is able to send packed type' do
        subject.send(type)

        data = @i3_srv.receive(14)
        header = subject.unpack_header data
        expect(header).to match_array [Protocol::MAGIC_STRING, 0, type]
      end

      it 'is able to send packed type and payload' do
        subject.send(type, message)

        data = @i3_srv.receive(14)
        header = subject.unpack_header data
        expect(header).to match_array [Protocol::MAGIC_STRING, message.size, type]

        data = @i3_srv.receive(header[1])
        expect(data).to eq message
      end

      it 'throws error if not connected' do
        subject.disconnect
        expect { subject.send(type) }.to raise_error
      end
    end

    describe '#receive', :i3 => :simulate do
      let(:type) { 40 }
      let(:message) { 'test_receive' }

      context 'if server send packed message' do
        before (:each) do
          data = subject.pack(type, message)
          @i3_srv.send(data)
        end

        it 'returns unpacked message' do
          recv_message = subject.receive
          expect(recv_message).to eq(message)
        end

        it 'throws WrongType if received type does not match expected one' do
          expect { subject.receive(type + 1) }.to raise_error Protocol::WrongType
        end
      end

      context 'if server send wrong message' do
        before (:each) do
          data = 'i4-ipc' + [message.size, type].pack("LL") + message
          @i3_srv.send(data)
        end

        it 'throws WrongMagicString' do
          expect { subject.receive(type) }.to raise_error Protocol::WrongMagicString
        end
      end

      it 'throws error if not connected' do
        subject.disconnect
        expect { subject.receive }.to raise_error Protocol::NotConnected
      end
    end
  end
end

