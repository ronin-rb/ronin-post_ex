require 'spec_helper'
require 'ronin/post_ex/captured_file'

describe Ronin::PostEx::CapturedFile do
  let(:path) { '/path/to/file.txt' }
  let(:data) { "foo\nbar\nbaz\n"   }

  subject { described_class.new(path,data) }

  describe "#initialize" do
    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    it "must populate the contents" do
      expect(subject.string).to eq(data)
    end
  end
end
