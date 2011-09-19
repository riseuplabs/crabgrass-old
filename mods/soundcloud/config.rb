class SoundcloudClient < ActiveRecord::Base
  #
  # please insert your Soundcloud Client Data here.
  #
  if RAILS_ENV == 'production'
    CLIENT_ID = "425ea22f3dacba9c007601d97e4ffbf4"
    CLIENT_SECRET = "7f10cdc82a26e6f49429da4bdbfe969a"
  else
    CLIENT_ID = "eee3f3174759328707c73a0be2652fce"
    CLIENT_SECRET = "bce994a5f79e241cbe94e4035e4a224b"
  end

end

