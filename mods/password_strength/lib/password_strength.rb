# http://www.codeandcoffee.com/2007/06/27/how-to-make-a-password-strength-meter-like-google/
# http://snippets.dzone.com/posts/show/4698

# the PW strength is the amount of time needed to bruteforce a password in
# years, at approximately 1000 tries per second.
# I don't know what a good value would be, just tried around a litte


module PasswordStrength

  PASSWORD_SETS = {
    /[a-z]/ => 26,
    /[A-Z]/ => 26,
    /[0-9]/ => 10,
    /[^\w]/ => 32
  }

  def self.check_strength(password)
    return false unless password.any?
    set_size = 0
    PASSWORD_SETS.each_pair {|k,v| set_size += v if password =~ k}
    combinations = set_size ** password.length
    # assuming 1000 tries per second
    days = combinations.to_f / 1000 / 86400
    (days / 365) > MIN_PASSWORD_STRENGTH
  end

end

