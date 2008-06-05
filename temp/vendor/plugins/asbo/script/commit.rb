#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'asbo')

Asbo::pre_commit

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

Asbo::post_commit