# -*- mode: ruby -*-
# vi: set ft=ruby :

module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end


# used to inject files in another one
def inject_file(file_to_insert, destination_file, marker)

  # load the file as a string
  to_inject  = File.read(file_to_insert)
  to_receive = File.read(destination_file)
  # globally substitute "install" for "latest"
  filtered_data = to_receive.gsub(marker, to_inject)

  # open the file for writing
  File.open(destination_file, "w") do |f|
    f.write(filtered_data)
  end
end

def inject(destination_file, marker, variable)

  # load the file as a string
  to_receive = File.read(destination_file)

  # globally substitute "install" for "latest"
  filtered_data = to_receive.gsub(marker, variable)

  # open the file for writing
  File.open(destination_file, "w") do |f|
    f.write(filtered_data)
  end
end

