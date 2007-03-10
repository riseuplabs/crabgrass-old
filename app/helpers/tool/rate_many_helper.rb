module Tool::RateManyHelper
  @@map = {
     2 => 'good', 'good' =>  2,
     1 => 'ok'  , 'ok'   =>  1,
     0 => 'none', 'none' =>  0,
    -1 => 'bad' , 'bad'  => -1,
    -2 => 'no'  , 'no'   => -2,
  }
  def map(value)
    @@map[value]
  end
end
