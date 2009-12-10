task :create_a_secret do
  path = File.join(RAILS_ROOT, "config/secret.txt")
  `rake -s secret > #{path}`
end
