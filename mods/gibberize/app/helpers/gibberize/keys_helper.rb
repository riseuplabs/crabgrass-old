module Gibberize::KeysHelper

  def key_path(arg, options={})
    gibberize_key_path(arg,options)
  end

  def edit_key_path(arg)
    edit_gibberize_key_path(arg)
  end
 
  def new_key_path
    new_gibberize_key_path
  end

  def keys_path
    gibberize_keys_path
  end

  def key_url(arg, options={})
    gibberize_key_url(arg, options)
  end
end
