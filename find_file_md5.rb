#!/usr/bin/ruby -w
require 'find'
require 'digest/md5'

# Find files based on it's md5sum 
# http://unix.stackexchange.com/questions/119098/is-there-any-way-to-find-a-file-when-you-know-its-checksum/119111?noredirect=1#119111

file_md5sum_to_match = [ '304a5fa2727ff9e6e101696a16cb0fc5',
                         '0ce6742445e7f4eae3d32b35159af982' ]

Find.find('/') do |f|
  # skip if f is  a device file, pipe, socket, etc
  next unless ( File.file?(f) && File.readable?(f) && !File.zero?(f) )
  next if /(^\.|^\/proc|^\/sys)/.match(f) # skip
 
  begin
        md5sum = Digest::MD5.hexdigest(File.read(f))
  rescue
        puts "Error reading #{f} --- MD5 hash not computed."
  end
  
  if file_md5sum_to_match.include?(md5sum)
       puts "File Found at: #{f}"
       file_md5sum_to_match.delete(md5sum)
  end
  
  file_md5sum_to_match.empty? && exit # if array empty then exit

end
