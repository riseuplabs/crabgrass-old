require 'tempfile'
require 'fileutils'

##
## A thin wrapper to help make generating GPG keyrings easier
##

class Keyring
  attr_accessor :path

  def initialize(path)
    @path = path
  end

  def self.create(public_key_data, path)
    key_file = Tempfile.new('crabgrass_public_key')
    key_file.write(public_key_data)
    key_file.close

    FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))

    keyring = Keyring.new(path)
    status, output = keyring.cmd('--import', key_file.path)
    return keyring if status
  ensure
    key_file.unlink
  end

  # extract information from a keyring that has one key in it.
  # the information includes: fingerprint, email
  def extract_info
    fingerprint = nil
    email = nil

    status, output = cmd('--fingerprint', '--with-colons')
    if status
      fingerprint  = output.grep(/^fpr/).first.sub(/^.*:([A-F0-9]{40}):.*$/m, '\1') rescue Exception
      email        = output.grep(/^pub/).first.split(':')[9] rescue Exception
    end
    {:fingerprint => fingerprint, :email => email}
  end

  def encrypt_to(fingerprint, data)
    data_file = Tempfile.new('crabgrass_tmp')
    data_file.write(data)
    data_file.close

    output_path = random_temp_filename(fingerprint)
    cmd('--encrypt', '--armor', '--recipient', fingerprint, '--trust-model', 'always', '--output', output_path, data_file.path)
    File.read(output_path)
  ensure
    data_file.unlink
    File.unlink(output_path)
  end

  def cmd(*args)
    cmdstr = "#{GPG_COMMAND} --no-default-keyring --keyring #{@path} " + args.collect{|arg| arg.shell_escape}.join(' ') + ' 2>&1'
    output = `#{cmdstr}`
    return [$?.success?, output]
  end

  def random_temp_filename(fingerprint)
    "/tmp/#{rand 100000}{fingerprint}"
  end

end

