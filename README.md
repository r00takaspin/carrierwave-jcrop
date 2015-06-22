# CarrierWave-Jcrop

CarrierWave extension to crop uploaded images using Jcrop plugin with support of mongoid.
Fork of https://github.com/kirtithorat/carrierwave-crop gem

## Installation

Install the latest stable release:

    $[sudo] gem install carrierwave-jcrop

In Rails, add it to your Gemfile:

    gem 'carrierwave-jcrop'

And then execute:

    $ bundle

Finally, restart the server to apply the changes.

## Getting Started

Add the required files in assets

In  `application.js`

    //= require jquery
    //= require jquery.Jcrop

In  `application.css`

    *= require jquery.Jcrop

## Usage

Open your model file and add the cropper:

    class User
      include Mongoid::Document
      include CarrierWave::Jcrop
      mount_uploader :avatar, AvatarUploader
      crop_uploaded :avatar  ## Add this
    end

For `Rails 4.x`, whitelist the cropping attributes - `fieldname_crop_x`, `fieldname_crop_y`, `fieldname_crop_w`, `fieldname_crop_h`.

For example:

    def user_params
      params.require(:user).permit(:avatar_crop_x, :avatar_crop_y, :avatar_crop_w, :avatar_crop_h, ....)
    end


In the view, say `crop.html.erb`:

    <%= form_for @user do |f| %>
      <%= f.cropbox :avatar %>
      <%= f.previewbox :avatar %>
      <%= f.submit 'Crop' %>
    <% end %>

By adding `cropbox` helper to your form, helper will render image and crop grid over it.

In the carrierwave uploader, say `AvatarUploader`:

Call process on the version you would like to be cropped:

    ## If ONLY "thumb" version is to be cropped
    version :jumbo do
      resize_to_limit(600,600)
    end

    version :thumb do
      process crop: :avatar  ## Crops this version based on original image
      resize_to_limit(100,100)
    end

If there are no versions, and original file is to be cropped directly then call the process directly within `AvatarUploader`,

    process crop: :avatar

##NOTES

1. Current Documentation is for **CarrierWave-Crop v0.1.2**
2. Supports processors `rmagick` and `mini-magick`.

   **To use `rmagick`, add it in your `Gemfile` as:**

        gem 'rmagick', :require => 'RMagick'  ## Specify appropriate version, if needed

   Run `bundle`

   Include it in your CarrierWave Uploader. For example:

        class AvatarUploader < CarrierWave::Uploader::Base
          include CarrierWave::RMagick
          ## ...
        end

    **To use `mini_magick`, add it in your `Gemfile` as:**

        gem 'mini_magick'  ## Specify appropriate version, if needed

   Run `bundle`

   Include it in your CarrierWave Uploader. For example:

        class AvatarUploader < CarrierWave::Uploader::Base
          include CarrierWave::MiniMagick
          ## ...
        end

3. Supports cropping of ONE attachment per model. Can be directly applied on original attachment if no versions exists.

        process crop: :avatar

4. Supports cropping of MULTIPLE versions of one attachment per model.
5. In form helpers, by default *original image* is rendered. To render a specific version for cropping pass `version` option. For example:

        <%= f.cropbox :avatar , version: :medium %>
        <%= f.previewbox :avatar , version: :medium %>  ## Pass the same version as specified in cropbox

6. By default `previewbox` has `100x100` dimensions and `cropbox` defaults to the target geometry for the version.
   `width` and `height` can be specified for these form helpers. BUT If you override ONE of width/height you MUST override both, otherwise passed option would be ignored.

        <%= f.cropbox :avatar, width: 550, height: 600 %>
        <%= f.previewbox :avatar, width: 200, height: 200 %>

7. By default, `process crop: :avatar` will create the cropped version based on original image.
   To resize the image to a particular dimension before cropping, pass two more arguments `width` and `height`.

        ## If ONLY "thumb" version is to be cropped
        version :jumbo do
          resize_to_limit(600,600)
        end

        version :thumb do
          ## To crop this version based on `jumbo` version, pass width = 600 and height = 600
          ## Specify both width and height values otherwise they would be ignored
          process crop: [:avatar, 600, 600]
          resize_to_limit(100,100)
        end

### Credits and resources
* [CarrierWave](https://github.com/carrierwaveuploader/carrierwave)
* [Deep Liquid's JCrop](http://deepliquid.com/content/Jcrop.html)
* And Ryan Bates [Railscast#182](http://railscasts.com/episodes/182-cropping-images/)