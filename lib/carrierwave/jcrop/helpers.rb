module CarrierWave
  module Jcrop
    module Helpers

      # Form helper to render the preview of a cropped attachment.
      # Loads the actual image. Previewbox has no constraints on dimensions, image is renedred at full size.
      # By default box size is 100x100. Size can be customized by setting the :width and :height option.
      # If you override one of width/height you must override both.
      # By default original image is rendered. Specific version can be specified by passing version option
      #
      #   previewbox :avatar
      #   previewbox :avatar, width: 200, height: 200
      #   previewbox :avatar, version: :medium
      #
      # @param attachment [Symbol] attachment name
      # @param opts [Hash] specify version or width and height options
      def previewbox(attachment, opts = {})
        attachment = attachment.to_sym

        if(self.object.send(attachment).class.ancestors.include? CarrierWave::Uploader::Base )
          ## Fixes Issue #1 : Colons in html id attributes with Namespaced Models
          model_name = self.object.class.name.downcase.split("::").last
          width, height = 100, 100
          if(opts[:width] && opts[:height])
            width, height = opts[:width].round, opts[:height].round
          end
          wrapper_attributes = {id: "#{model_name}_#{attachment}_previewbox_wrapper", style: "width:#{width}px; height:#{height}px; overflow:hidden"}
          if opts[:version]
            img = self.object.send(attachment).url(opts[:version])
          else
            img = self.object.send(attachment).url
          end
          preview_image = @template.image_tag(img, id: "#{model_name}_#{attachment}_previewbox")
          @template.content_tag(:div, preview_image, wrapper_attributes)
        end
      end

      # Form helper to render the actual cropping box of an attachment.
      # Loads the actual image. Cropbox has no constraints on dimensions, image is renedred at full size.
      # Box size can be restricted by setting the :width and :height option. If you override one of width/height you must override both.
      # By default original image is rendered. Specific version can be specified by passing version option
      #
      #   cropbox :avatar
      #   cropbox :avatar, width: 550, height: 600
      #   cropbox :avatar, version: :medium
      #
      # @param attachment [Symbol] attachment name
      # @param opts [Hash] specify version or width and height options
      def cropbox(attachment, opts={})
        attachment = attachment.to_sym
        object = self.object
        attachment_instance = self.object.send(attachment)

        if(attachment_instance.class.ancestors.include?(CarrierWave::Uploader::Base) && object.send(attachment).present?)
          ## Fixes Issue #1 : Colons in html id attributes with Namespaced Models
          model_name = self.object.class.name.downcase.split("::").last
          hidden_elements  = self.hidden_field(:"#{attachment}_crop_x", id: "#{model_name}_#{attachment}_crop_x")
          [:crop_y, :crop_w, :crop_h].each do |attribute|
            hidden_elements << self.hidden_field(:"#{attachment}_#{attribute}", id: "#{model_name}_#{attachment}_#{attribute}")
          end

          box =  @template.content_tag(:div, hidden_elements, style: "display:none")

          wrapper_attributes = {id: "#{model_name}_#{attachment}_cropbox_wrapper"}
          if(opts[:width] && opts[:height])
            wrapper_attributes.merge!(style: "width:#{opts[:width].round}px; height:#{opts[:height].round}px; overflow:hidden")
          end

          if opts[:version]
            img = self.object.send(attachment).url(opts[:version])
          else
            img = self.object.send(attachment).url
          end
          img_id = "#{model_name}_#{attachment}_cropbox"
          img_styles = {}
          if opts[:bg_color]
            crop_image = @template.image_tag(img, :id => img_id,style:"background-color:#{opts[:bg_color]}")
          else
            crop_image = @template.image_tag(img, :id => img_id)
          end

          box << @template.content_tag(:div, crop_image, wrapper_attributes)
          box << init_jcrop(img_id,attachment,object)
          box
        end
      end

      private
      def coordinates_set?(attachment,object)
        if object.respond_to?("#{attachment}_crop_params") && !object.send("#{attachment}_crop_params").nil?
          %w(crop_x crop_y crop_w crop_h).each do |p|
            return false unless object.send("#{attachment}_crop_params").has_key?(p)
          end
          true
        else
          false
        end
      end

      def init_jcrop(img_id,attachment,object)
          model_name = object.class.to_s.downcase
          if coordinates_set?(attachment,object)
            x,y,x1,y1 = set_coordinates(object,attachment)
          else
            x,y,x1,y1 = 0,0,200,200
          end
          @template.javascript_tag(%Q(
            $(document).ready(function() {
              $("##{img_id}").Jcrop({
                setSelect: [#{x}, #{y}, #{x1}, #{y1}],
                onSelect: function(coords) {
                      $('##{model_name}_#{attachment}_crop_x').val(coords.x)
                      $('##{model_name}_#{attachment}_crop_y').val(coords.y)
                      $('##{model_name}_#{attachment}_crop_w').val(coords.w)
                      $('##{model_name}_#{attachment}_crop_h').val(coords.h)
                },
                onUpdate: function(coords) {
                      $('##{model_name}_#{attachment}_crop_x').val(coords.x)
                      $('##{model_name}_#{attachment}_crop_y').val(coords.y)
                      $('##{model_name}_#{attachment}_crop_w').val(coords.w)
                      $('##{model_name}_#{attachment}_crop_h').val(coords.h)
                }
              });
            });)
          )
      end

      def set_coordinates(object,attachment)
          x = object.send("#{attachment}_crop_params")["crop_x"].to_i
          y = object.send("#{attachment}_crop_params")["crop_y"].to_i
          x1 = object.send("#{attachment}_crop_params")["crop_x"].to_i + object.send("#{attachment}_crop_params")["crop_w"].to_i
          y1 = object.send("#{attachment}_crop_params")["crop_y"].to_i + object.send("#{attachment}_crop_params")["crop_h"].to_i
          return x,y,x1,y1
      end
    end
  end
end

if defined? ActionView::Helpers::FormBuilder
  ActionView::Helpers::FormBuilder.class_eval do
    include CarrierWave::Jcrop::Helpers
  end
end