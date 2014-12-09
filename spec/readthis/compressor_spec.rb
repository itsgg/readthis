require 'readthis/compressor'

RSpec.describe Readthis::Compressor do
  describe '#compress' do
    it 'compresses the input' do
      compressor   = Readthis::Compressor.new(threshold: 0)
      input      = 'aaa bbb ccc'
      output     = compressor.compress(input)

      expect(input).not_to eq(output)
    end

    it 'passes input below the threshold size through uncompressed' do
      compressor = Readthis::Compressor.new(threshold: 1024)
      input      = 'abcdefg'

      expect(compressor.compress(input)).to eq(input)
    end
  end

  describe '#decompress' do
    it 'decompresses compressed data' do
      compressor   = Readthis::Compressor.new(threshold: 0)
      input        = 'aaa bbb ccc'
      compressed   = compressor.compress(input)
      decompressed = compressor.decompress(compressed)

      expect(decompressed).to eq(input)
    end

    it 'passes through decompression failures' do
      compressor = Readthis::Compressor.new(threshold: 0)
      input      = 'abcdefg'

      expect(compressor.decompress(input)).to eq(input)
    end
  end
end
