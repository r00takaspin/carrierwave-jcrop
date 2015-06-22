require 'carrierwave/jcrop'

class SampleModel
  include Mongoid::Document
  include CarrierWave::Jcrop

  mount_uploader :avatar, AvatarUploader
  crop_uploaded :avatar
end

