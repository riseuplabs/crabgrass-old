# do this early because environments/*.rb need it
require File.dirname(__FILE__) + '/conf'

# load hook support early
require File.dirname(__FILE__) + '/hook'

# load Crabgrass::Initializer early
require File.dirname(__FILE__) + '/initializer'

Conf.load("crabgrass.#{RAILS_ENV}.yml")

begin
  secret_path = File.join(RAILS_ROOT, "config/secret.txt")
  Conf.secret = File.read(secret_path).chomp
rescue
  unless ARGV.first == "create_a_secret"
    raise "Can't load the secret key from file #{secret_path}. Have you run 'rake create_a_secret'?"
  end
end

# TODO: banish SECTION_SIZE and replace with current_site.pagination_size
SECTION_SIZE = Conf.pagination_size

