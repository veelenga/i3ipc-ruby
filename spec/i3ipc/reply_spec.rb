require 'spec_helper'

module I3Ipc
  describe Reply do

    describe '.parse' do
      context 'when valid JSON string passed' do

        it 'properly parses boolean attributes' do
          expect(Reply.parse('{"success": true}').success).to be true
          expect(Reply.parse('{"success": false}').success).to be false
        end

        it 'properly parses numeric attributes' do
          reply = Reply.parse(%Q[{ "int": 2, "float": 4.2 }])
          expect(reply.int).to be 2
          expect(reply.float).to be 4.2
        end

        it 'properly parses string attributes' do
          expect(Reply.parse('{"output": "LVDS1"}').output).to eql "LVDS1"
        end

        it 'properly parses array of hashes' do
          reply = Reply.parse( %Q[{ "data": [{"key1": true}, {"key2": false}] }])
          expect(reply.data[0].key1).to be true
          expect(reply.data[1].key2).to be false
        end

        it 'properly parses sub-hashes' do
          reply = Reply.parse(%Q[{ "data":{ "key1": "val1", "key2": "val2"} }])
          expect(reply.data.key1).to eql 'val1'
          expect(reply.data.key2).to eql 'val2'
        end

        it 'properly parses sub-arrays' do
          reply = Reply.parse(%Q[{ "data": [[ 1, 2 ]] }])
          expect(reply.data[0]).to match_array [1, 2]
        end

        it 'properly parses empty array' do
          reply = Reply.parse(%Q[{"ar" : []}])
          expect(reply.ar).to be_a Array
          expect(reply.ar).to be_empty
        end

        it 'property parses empty hash' do
          reply = Reply.parse(%Q[{"ha": {}}]);
          expect(reply.ha).to be_a Reply
          expect(reply.ha.to_s).to eq '{}'
        end

        it 'returns new Reply object' do
          expect(Reply.parse('{}')).to be_a Reply
        end
      end

      context 'when NOT valid JSON string passed' do
        it 'raise JSON::ParserError' do
          expect{Reply.parse(%Q[{"data": }])}.to raise_error JSON::ParserError
        end
      end
    end

    describe '#to_s' do
      it 'returns #to_json called on passed data' do
        hash = {:one => 'one', :two => 'two'}
        reply = Reply.new(hash)
        expect(reply.to_s).to eql hash.to_json
      end
    end

    describe '#method_missing' do
      it 'returns value with dynamic method based on input data' do
        expect(Reply.new({:meth => 'val'}).meth).to eql 'val'
      end

      it 'throws ArgumentError if one or more parameters passed to dynamic method' do
        expect{ Reply.new({:meth => 'val'}).meth(0) }.to raise_error ArgumentError
      end

      it 'still throws NoMethodError if not existed method called' do
        expect{ Reply.new({:meth => 'val'}).no_such_method }.to raise_error NoMethodError
      end
    end

    describe '#respond_to' do
      it 'responds to method from input data' do
        expect(Reply.new({:meth => 'val'})).to respond_to :meth
      end

      it 'still does not respond to not existed methods' do
        expect(Reply.new({:meth => 'val'})).not_to respond_to :no_such_method
      end
    end
  end
end
