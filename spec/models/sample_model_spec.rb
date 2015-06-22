require 'spec_helper'

describe SampleModel do
  before(:all) {
    Mongoid::Config.connect_to("carrierwave_jcrop_test")
  }
  subject(:model) {
    SampleModel.new
  }

  it 'should have crop fields' do
    expect(model.respond_to?(:avatar_crop_x)).to eq(true)
    expect(model.respond_to?(:avatar_crop_y)).to eq(true)
    expect(model.respond_to?(:avatar_crop_w)).to eq(true)
    expect(model.respond_to?(:avatar_crop_h)).to eq(true)
  end

  it 'try crop' do
    model.avatar_crop_x = 0
    model.avatar_crop_y = 0
    model.avatar_crop_w = 100
    model.avatar_crop_h = 150
    model.avatar = Rack::Test::UploadedFile.new("#{Dir.pwd}/spec/caps/cap.jpg")
    model.save!
  end
end