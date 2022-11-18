require 'spec_helper'
require 'ronin/post_ex/system'
require 'ronin/post_ex/sessions/session'

describe Ronin::PostEx::System do
  let(:session) { Ronin::PostEx::Sessions::Session.new }

  subject { described_class.new(session) }

  describe "#initialize" do
    it "must set #session" do
      expect(subject.session).to be(session)
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
      expect(session).to receive(:sys_time).and_return(unix_timestamp)

      expect(subject.time).to eq(time)
    end
  end

  describe "#hostname" do
    let(:hostname) { 'computer' }

    it "must call the 'sys_hostname' API function and return the hostname" do
      expect(session).to receive(:sys_hostname).and_return(hostname)

      expect(subject.hostname).to eq(hostname)
    end
  end
end
