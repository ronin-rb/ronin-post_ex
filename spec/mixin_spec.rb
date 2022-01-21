require 'spec_helper'
require 'ronin/post_ex/mixin'

describe Mixin do
  subject do
    obj = Object.new
    obj.extend described_class
    obj
  end

  describe "#fs" do
    it "must return a Resources::FS object" do
      expect(subject.fs).to be_kind_of(Resources::FS)
    end
  end

  describe "#process" do
    it "must return a Resources::Process object" do
      expect(subject.process).to be_kind_of(Resources::Process)
    end
  end

  describe "#shell" do
    it "must return a Resources::Shell object" do
      expect(subject.shell).to be_kind_of(Resources::Shell)
    end
  end
end
