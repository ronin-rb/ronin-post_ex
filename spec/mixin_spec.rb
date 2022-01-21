require 'spec_helper'
require 'ronin/post_ex/mixin'

describe PostEx::Mixin do
  subject do
    obj = Object.new
    obj.extend PostEx::Mixin
    obj
  end

  it "should lazily initialize controlled resources objects" do
    expect(subject.resources).to be_empty
    expect(subject.resources[:shell]).not_to be_nil
  end

  it "should not provide access to other resources" do
    expect(subject.resources[:foo]).to be_nil
  end

  it "should define methods for accessing the resources" do
    expect(subject).to respond_to(:fs)
  end
end