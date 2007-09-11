############################################
## Some helpful functions that have nowhere else to go
##

def max(a,b)
  a >= b ? a : b
end

def max_mtime(glob_expr)
  Dir.glob(glob_expr).inject(0) do |maxtime,filename|
    t = File.mtime(filename).to_i
    max(maxtime, t)
  end
end


