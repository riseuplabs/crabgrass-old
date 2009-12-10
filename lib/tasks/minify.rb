# This task minifies and then compresses the crabgrass javascript.
# It should be run every time you modify the code in one of the javascript files.
#
# Only some scripts are combined and compressed: only scripts specified
# by constants that end in _JS and are defined in layout_helper.rb
#
# There are a couple of reasons we might want to use this method instead of
# of the many other possibilities:
#
# (0) we want both minification and compression
# (1) it is nice to be able to run yuicompressor manually, in case there are errors.
# (2) it is nice to be able to use --best compression for gzip.
# (3) it is better to compress in advance, rather than on every request (ie apache deflate)
#
# These minified and compressed versions are only used in production mode.
#
# The compressed files are only used if you have configured apache correctly:
#
# AddEncoding gzip .gz
# RewriteCond %{HTTP:Accept-encoding} gzip
# RewriteCond %{HTTP_USER_AGENT} !Safari
# RewriteCond %{REQUEST_FILENAME}.gz -f
# RewriteRule ^(.*)$ $1.gz [QSA,L]
#
# (1) The first line tells the server that files with .gz extensions should be
#     served with the gzip encoding-type, so the browser knows what to do with them.
# (2) The second line checks that the browser will accept gzipped content -- the
#     following lines will not be executed if this test fails.
# (3) We exclude Safari as it doesn’t interpret the gzipped content correctly.
#     (Is this still true?)
# (4) We check that this gzipped version of the file exists (fourth line)
# (5) If all the prior checks pass, then we append .gz to the requested filename.
#

# if minify_source is true, then the files passed in will get replaced with the
# the minified versions
def compressor(files, minify_source=false)
  files.each do |file|
    return if File.symlink?(file)
    path = File.dirname(File.dirname(__FILE__))
    if minify_source
      out_file = file
    else
      out_file = '/tmp/' + File.basename(file)
    end

    verbose = ENV["VERBOSE"] ? '--verbose' : ''
    cmd = "java -jar #{path}/bin/yuicompressor-2.4.2.jar --line-break 200 #{verbose} #{file} -o #{out_file}"
    puts cmd
    ret = system(cmd)
    raise "Minification failed for #{file}" if !ret
    cmd = "gzip --rsyncable --best -c #{out_file} > #{file}.gz"
    puts cmd
    ret = system(cmd)
    raise "Compression failed for #{file}" if !ret
  end
end

# hash in the form: {:bundlename => ['file1','file2']}
def join_files(hash)
  output = hash.keys.first.to_s + '.js'
  files = hash.values.first
  cmd = 'cat %s > %s' % [files.collect{|f|f+".js"}.join(' '), output]
  puts cmd; system(cmd)
end

desc "minify javascript"
task :minify do
  chdir(File.dirname(__FILE__) + '/../../public/javascripts')
  if ENV["FILE"]
    compressor(ENV["FILE"])
  else

    # grab definitions for MAIN_JS, EXTRA_JS, and WIKI_JS
    script_file_constants = `grep '_JS = ' ../../app/helpers/layout_helper.rb`
    eval(script_file_constants)

    join_files(MAIN_JS)
    join_files(EXTRA_JS)
    join_files(WIKI_JS)

    compressor('main.js', true)
    compressor('extra.js', true)
    compressor('wiki.js', true)
  end
end

#desc "minify css"
#task :minify_css do
#  compressor(FileList['public/stylesheets/**/*.css'])
#end
