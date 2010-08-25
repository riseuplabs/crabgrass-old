# we don't load any source files from here, because they get
# loaded by 'boot.rb' earlier on in the rails startup

#
# this is not used, but might be useful if we need some early initialization:
#
## Only call Mods.init once, in the after_initialize block so that Rails
## plugin reloading works when turned on
#config.after_initialize do
#  Mods.init(initializer) if defined? :Mods
#end

