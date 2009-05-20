class Zip::ZipFile
  def initialize(file, create=nil)
    if file.kind_of?(String)
      super
    else
      @name = file.original_filename
      @comment = ''
      read_from_stream(file)
      create = false
      storedEntries = @entrySet.dup
      @restore_ownership = false
      @restore_permissions = false
      @restore_times = true
    end
  end
end
