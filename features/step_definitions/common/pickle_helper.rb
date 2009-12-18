# a table should be able to contain a model label like this:
# | user | display_name |
# | red  | Red!         |
# | blue | Blue!        |
# here the _name_ method argument is "user" (the model class)
# and the hash is something like {"user"=>"red", "display_name"=>"Red!"}
# it should return 'user: "red"'
# this method modifies the _hash_ by removing the model_name key from it
def extract_model_label_from_table_hash!(model_name, hash)
  # {"user" => "gerrard"}.delete("user")
  model_label = hash.delete(model_name)

  if model_label
    # "user: \"gerrard\""
    "#{model_name}: \"#{model_label}\""
  else
    model_name
  end
end