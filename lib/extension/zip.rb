class BetterZipFile < Zip::ZipFile
  # Zip::ZipFile is unable to handle open files, it only takes filenames as
  # arguments. Extending ZipFile is practically impossible due to excessive use
  # of `super' in their code that makes it impossible to keep track of what gets
  # actually executed and what doesn't.
  def initialize(file)
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
