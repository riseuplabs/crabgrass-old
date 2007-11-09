#
# An IntArray is an array that can serialize itself to a binary form
# using BER compressed integers. Thus, any size integer is allowed, but
# it is serialized in a space efficient form.
#
# For integers less than 16384, only two bytes are used per
# entry in the IntArray. 
# 
# The column type MUST BE BLOB, or IntArray will not serialize
# correctly when the numbers get above 2 digits.
#

class IntArray < Array
  def initialize(arg)
    if arg.instance_of? String
      super( arg.unpack('w*') )
    elsif arg.instance_of? Array
      super( arg.map{|i|i.to_i} )
    else
      super()
    end
  end
  def to_s
    self.pack('w*')
  end
  def to_sql
    self.any? ? self.join(',') : 'NULL'
  end
end

