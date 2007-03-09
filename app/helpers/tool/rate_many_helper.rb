module RateManyHelper

  @@map = {
     2 => 'good', 'good' =>  2,
     1 => 'ok'  , 'ok'   =>  1,
     0 => 'none', 'none' =>  0,
    -1 => 'bad' , 'bad'  => -1,
    -2 => 'no'  , 'no'   => -2,
  }

  def vote_num_to_str(value)
    @@map[value]
  end
  
  def vote_str_to_num(string)
    @@map[string]
  end
  

  def vote_str=(val)
    vote_weight = @@map[val]
  end

  def self.str_to_weight(str)
    @@map[str]
  end
end
