require 'spec_helper'
require 'ronin/post_ex/system'

describe Ronin::PostEx::System do
  let(:api) { double('Post-Exploitation API Object') }

  subject { described_class.new(api) }

  describe "#initialize" do
    it "must set #api" do
      expect(subject.api).to be(api)
    end

    it "must initialize #fs" do
      expect(subject.fs).to be_kind_of(described_class::FS)
    end

    it "must initialize #process" do
      expect(subject.process).to be_kind_of(described_class::Process)
    end

    it "must initialize #shell" do
      expect(subject.shell).to be_kind_of(described_class::Shell)
    end
  end

  describe "#fs" do
    it "must return a System::FS object" do
      expect(subject.fs).to be_kind_of(described_class::FS)
    end
  end

  describe "#process" do
    it "must return a System::Process object" do
      expect(subject.process).to be_kind_of(described_class::Process)
    end
  end

  describe "#shell" do
    it "must return a System::Shell object" do
      expect(subject.shell).to be_kind_of(described_class::Shell)
    end
  end

  describe "#time" do
    let(:unix_timestamp) { 1642775495 }
    let(:time)           { Time.at(unix_timestamp) }

    it "must call the 'sys_time' API function and return a Time object" do
      expect(api).to receive(:sys_time).and_return(unix_timestamp)

      expect(subject.time).to eq(time)
    end
  end
end
