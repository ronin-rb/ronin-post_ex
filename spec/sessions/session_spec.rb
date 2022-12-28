require 'spec_helper'
require 'ronin/post_ex/sessions/session'

describe Ronin::PostEx::Sessions::Session do
  describe "#name" do
    context "when #name is set" do
      module TestSession
        class SessionWithNameSet < Ronin::PostEx::Sessions::Session

          def initialize(name)
            @name = name
          end

        end
      end

      let(:name) { 'example-session' }

      subject { TestSession::SessionWithNameSet.new(name) }

      it "must return @name" do
        expect(subject.name).to eq(name)
      end
    end

    context "when @name is not set" do
      module TestSession
        class SessionWithoutNameSet < Ronin::PostEx::Sessions::Session
        end
      end

      subject { TestSession::SessionWithoutNameSet.new }

      it do
        expect {
          subject.name
        }.to raise_error(NotImplementedError,"#{subject.class}#name was not set")
      end
    end
  end

  describe "#to_s" do
    let(:name) { "host:port" }

    it "must call #name" do
      expect(subject).to receive(:name).and_return(name)

      expect(subject.to_s).to be(name)
    end
  end
end
