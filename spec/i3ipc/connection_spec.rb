require 'spec_helper'

module I3Ipc
  describe Connection do

    let(:protocol) { Protocol.new '' }
    let(:stub_protocol) do
      allow(protocol).to receive(:send)
      allow(protocol).to receive(:receive)
    end
    subject { Connection.new protocol, false }

    describe '#command' do
      it 'returns i3ipc reply' do
        stub_protocol.and_return('{}')
        expect(subject.command('cmd')).to be_a Reply
      end

      it 'sends correct command and receives success response' do
        stub_protocol.and_return({ success: true }.to_json)
        expect(subject.command('focus left').success?).to be true
      end

      it 'sends incorrect command and receives error response' do
        stub_protocol.and_return({ success: false, error: 'wrong command' }.to_json)
        reply = subject.command('my command')
        expect(reply.success).to be false
        expect(reply.error).to eql 'wrong command'
      end
    end

    describe '#workspaces' do
      it 'returns i3ipc reply' do
        stub_protocol.and_return('{}')
        expect(subject.workspaces).to be_a Reply
      end
    end

    describe '#outputs' do
      it 'returns i3ipc reply' do
        stub_protocol.and_return('{}')
        expect(subject.outputs).to be_a Reply
      end
    end

    describe '#tree' do
      it 'returns i3ipc reply' do
        stub_protocol.and_return('{}')
        expect(subject.tree).to be_a Reply
      end
    end

    describe '#marks' do
      it 'returns i3ipc reply' do
        stub_protocol.and_return('{}')
        expect(subject.marks).to be_a Reply
      end
    end

    describe '#bar_config' do
      it 'returns i3ipc reply' do
        stub_protocol.and_return('{}')
        expect(subject.bar_config).to be_a Reply
      end
    end

    describe '#version' do
      it 'returns i3ipc reply' do
        stub_protocol.and_return('{}')
        expect(subject.version).to be_a Reply
      end

      it 'able to parse version attributes' do
        resp = { human_readable: '4.2', minor: 2, patch: 0, major: 4 }
        stub_protocol.and_return(resp.to_json)
        reply = subject.version
        expect(reply.human_readable).to eq resp[:human_readable]
        expect(reply.minor).to eq resp[:minor]
        expect(reply.patch).to eq resp[:patch]
        expect(reply.major).to eq resp[:major]
      end
    end
  end
end
