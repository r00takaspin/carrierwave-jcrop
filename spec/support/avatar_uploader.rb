class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  process crop: :avatar

  version :thumb do
    process resize_to_fill: [50,50]
  end

  version :thumb_150x150 do
    process resize_to_fit: [100,150]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end