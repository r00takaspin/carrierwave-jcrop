require "carrierwave/jcrop/version"
require "carrierwave/jcrop/engine"
require "carrierwave/jcrop/helpers"
require 'pry'

module CarrierWave
  module Jcrop
    extend ActiveSupport::Concern

    module ClassMethods

      def crop_uploaded(attachment)

        field :"#{attachment}_crop_params",type: Hash

        [:crop_x,:crop_y,:crop_h,:crop_w].each do |coord|
          attr_accessor :"#{attachment}_#{coord}"
        end
        '''
        field :"#{attachment}_crop_x",type: Integer
        field :"#{attachment}_crop_y",type: Integer
        field :"#{attachment}_crop_h",type: Integer
        field :"#{attachment}_crop_w",type: Integer
        '''
        before_save do
          if cropping?(attachment)
            self.send(:"#{attachment}_crop_params=",{
                 :crop_x=>self.send("#{attachment}_crop_x"),
                 :crop_y=>self.send("#{attachment}_crop_y"),
                 :crop_h=>self.send("#{attachment}_crop_h"),
                 :crop_w=>self.send("#{attachment}_crop_w")
             })
          end
        end

        after_save do |doc|
          crop_image(attachment)
        end

        include CarrierWave::Jcrop::LocalInstanceMethods

      end
    end

    module LocalInstanceMethods

      # Checks if the attachment received cropping attributes
      # @param  attachment [Symbol] Name of the attribute to be croppedv
      #
      # @return [Boolean]
      def cropping?(attachment)
        !self.send(:"#{attachment}_crop_x").blank? &&
            !self.send(:"#{attachment}_crop_y").blank? &&
            !self.send(:"#{attachment}_crop_w").blank? &&
            !self.send(:"#{attachment}_crop_h").blank?
      end

      # Saves the attachment if the crop attributes are present
      # @param  attachment [Symbol] Name of the attribute to be cropped
      def crop_image(attachment)
        if cropping?(attachment)
          attachment_instance = send(attachment)
          attachment_instance.recreate_versions!
        end
      end

    end

    module Uploader
      # Performs cropping.
      #
      #  On original version of attachment
      #  process crop: :avatar
      #
      #  Resizes the original image to 600x600 and then performs cropping
      #  process crop: [:avatar, 600, 600]
      #
      # @param attachment [Symbol] Name of the attachment attribute to be cropped

      def crop(attachment, width = nil, height = nil)
        if model.cropping?(attachment)
          x = model.send("#{attachment}_crop_x").to_i
          y = model.send("#{attachment}_crop_y").to_i
          w = model.send("#{attachment}_crop_w").to_i
          h = model.send("#{attachment}_crop_h").to_i
          attachment_instance = model.send(attachment)

          if self.respond_to? "resize_to_limit"

            begin
              if width && height
                resize_to_limit(width, height)
              end
              manipulate! do |img|
                if attachment_instance.kind_of? CarrierWave::RMagick
                  img.crop!(x, y, w, h)
                elsif attachment_instance.kind_of? CarrierWave::MiniMagick
                  img.crop("#{w}x#{h}+#{x}+#{y}")
                  img
                end
              end

            rescue Exception => e
              raise CarrierWave::Crop::ProcessingError, "Failed to crop - #{e.message}"
            end

          else
            raise CarrierWave::Crop::MissingProcessorError, "Failed to crop #{attachment}. Add rmagick or mini_magick."
          end
        end
      end

    end

  end
end


if defined? CarrierWave::Uploader::Base
  CarrierWave::Uploader::Base.class_eval do
    include CarrierWave::Jcrop::Uploader
  end
end