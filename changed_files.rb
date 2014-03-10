#!/usr/bin/ruby -w
require 'find'
require 'digest/md5'

unless ARGV[0] and File.directory?(ARGV[0])
    puts "You need to specify a root directory: changedFiles.rb <directory>\n"
    exit
end

root = ARGV[0]
oldfile_hash = Hash.new
newfile_hash = Hash.new
file_report = "#{root}/analysis_report.txt"
file_output = "#{root}/file_list.txt"
oldfile_output = "#{root}/file_list.old"
check_time = Time.now.asctime

if File.exists?(file_output)
File.rename(file_output, oldfile_output)
File.open(oldfile_output, 'rb') do |infile|
        infile.each_line do |temp|
            line = /(.+\w) (\w{32,32})/.match(temp)
            #puts "#{line[1]} ---> #{line[2]}"
            oldfile_hash[line[1]] = line[2]
        end
    end
end

Find.find(root) do |file|
    next if /^\./.match(file) # skipp . .. 
    next unless File.file?(file) # skipp if not type file
    next if file =~ /(analysis_report.txt|file_list.txt|file_list.old)/ 
    begin
        newfile_hash[file] = Digest::MD5.hexdigest(File.read(file))
    rescue
        puts "Error reading #{file} --- MD5 hash not computed."
    end
end

report = File.new(file_report, 'ab')
changed_files = File.new(file_output, 'wb')
newfile_hash.each do |file, md5|
    changed_files.puts "#{file} #{md5}"
end
changed_files.close 

newfile_hash.keys.select { |file| newfile_hash[file] == oldfile_hash[file] }.each do |file|
    newfile_hash.delete(file)
    oldfile_hash.delete(file)
end


if newfile_hash == {} and oldfile_hash == {}
       puts "No Changed Made"
else 
	puts "Checking files..."
end

newfile_hash.each do |file, md5|
	if oldfile_hash[file] and md5 != oldfile_hash[file]
		puts "Changed: file #{file} #{md5}"
		report.puts "#{check_time} Changed: file #{file} #{md5}"
	else
		puts "Added: file: #{file} #{md5}"
		report.puts "#{check_time} Added: file: #{file} #{md5}"
	end
end

oldfile_hash.each do |file, md5|
    report.puts "#{check_time} Deleted/Moved file: #{file}"
    puts "Deleted/Moved file: #{file}"
    oldfile_hash.delete(file)
end
report.close
