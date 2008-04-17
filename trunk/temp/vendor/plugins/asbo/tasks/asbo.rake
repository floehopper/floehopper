require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rexml/document'
require 'digest/md5'
require 'yaml'

class Rake::Task
  def abandon
    @actions.clear
  end
  def overwrite(&block)
    abandon
    enhance(&block)
  end
end

namespace 'test' do
  
  Rake::Task['test:units'].abandon
  Rake::TestTask.new(:units => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
    t.on_result = lambda do |ok, status|
      tests_passed('test:units') if ok
    end
  end
  Rake::Task['test:units'].comment = "Run the unit tests in test/unit"
  
  Rake::Task['test:functionals'].abandon
  Rake::TestTask.new(:functionals => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/functional/**/*_test.rb'
    t.verbose = true
    t.on_result = lambda do |ok, status|
      tests_passed('test:functionals') if ok
    end
  end
  Rake::Task['test:functionals'].comment = "Run the functional tests in test/functional"
  
  Rake::Task['test:integration'].abandon
  Rake::TestTask.new(:integration => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = true
    t.on_result = lambda do |ok, status|
      tests_passed('test:integration') if ok
    end
  end
  Rake::Task['test:integration'].comment = "Run the integration tests in test/integration"
  
end

def tests_passed(test_task_name)
  abort "Warning: No test task name specified" if test_task_name.empty?
  
  FileUtils.mkdir_p(File.join('tmp', 'asbo'))
  data = { 'svn_base_revision' => svn_base_revision, 'svn_diff_md5' => svn_diff_md5 }
  filename = File.join('tmp', 'asbo', "#{test_task_name.gsub(/:/, '-')}.yml")
  File.open(filename, 'w') { |file| file.puts(data.to_yaml) }
end

def svn_base_revision
  svn_log = `svn log --revision BASE --xml`
  abort "Warning: unable to execute 'svn log'." unless $?.success?
  document = REXML::Document.new(svn_log)
  Integer(document.elements['/log/logentry'].attributes['revision'])
end

def svn_diff_md5
  svn_diff = `svn diff`
  abort "Warning: unable to execute 'svn diff'." unless $?.success?
  Digest::MD5.hexdigest(svn_diff)
end

namespace 'asbo' do

  task 'commit' do
    current_working_set = { 'svn_base_revision' => svn_base_revision, 'svn_diff_md5' => svn_diff_md5 }
    
    Dir.glob(File.join('tmp', 'asbo', '*.yml')).each do |filename|
      working_set = YAML.load(File.open(filename))
      unless current_working_set['svn_base_revision'] == working_set['svn_base_revision']
        abort "svn_base_revisions differ"
      end
      unless current_working_set['svn_diff_md5'] == working_set['svn_diff_md5']
        abort "svn_diff_md5s differ"
      end
    end
  end
  
end
