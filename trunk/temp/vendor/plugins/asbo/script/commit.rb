#!/usr/bin/env ruby

require 'yaml'
require File.join(File.dirname(__FILE__), '..', 'lib', 'asbo')

current_working_set = { 'svn_base_revision' => Asbo::svn_base_revision, 'svn_diff_md5' => Asbo::svn_diff_md5 }
errors = []
Dir.glob(File.join('tmp', 'asbo', '*.yml')).each do |filename|
  working_set = YAML.load(File.open(filename))
  unless current_working_set['svn_base_revision'] == working_set['svn_base_revision']
    errors << "svn_base_revisions differ for #{filename}"
  end
  unless current_working_set['svn_diff_md5'] == working_set['svn_diff_md5']
    errors << "svn_diff_md5s differ for #{filename}"
  end
end
abort errors.join("\n") unless errors.empty?

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on("-m arg", "--message arg", "specify log message ARG") do |m|
    options[:message] = m
  end
end.parse!

words = %w(svn commit)
words += options.map { |option, value| "--#{option} \"#{value}\"" }
words += ARGV
command = words.join(" ")

`#{command}`
abort "Warning: unable to execute '#{command}'." unless $?.success?

Dir.glob(File.join('tmp', 'asbo', '*.yml')).each do |filename|
  working_set = YAML.load(File.open(filename))
  working_set['svn_diff_md5'] = Asbo::svn_diff_md5
  File.open(filename, 'w') { |file| file.puts(working_set.to_yaml) }
end

