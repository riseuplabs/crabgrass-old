class AudioAsset < Asset

  # embed the audio file using JW Player
  # (a CC licensed Flash player, http://www.jeroenwijering.com/?item=JW_FLV_Media_Player)
  def embedding_partial
    'assets/audio_preview'
  end

end

