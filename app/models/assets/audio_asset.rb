class AudioAsset < Asset

  def update_media_flags
    self.is_audio = true
  end

  # embed the audio file using JW Player
  # (a CC licensed Flash player, http://www.jeroenwijering.com/?item=JW_FLV_Media_Player)
  def embedding_partial
    'assets/audio_preview'
  end

  define_thumbnails(
    :ogg => {:ext => 'ogg', :title => 'Ogg Audio', :proxy => true},
    :mp3 => {:ext => 'mp3', :title => 'MP3 Audio', :proxy => true}
  )

end

