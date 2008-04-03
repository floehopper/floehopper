task 'default' do
  Rake::Task['asbo:tests_passed'].invoke
end

require 'rexml/document'
require 'digest/md5'

namespace 'asbo' do
  
  desc 'Records the state of the svn working copy when the tests last passed'
  task 'tests_passed' => 'environment' do
    svn_log = `svn log --revision BASE --xml`
    unless $?.success?
      puts "Warning: unable to record the state of the svn working copy."
      exit
    end
    document = REXML::Document.new(svn_log)
    svn_base_revision = document.elements['/log/logentry'].attributes['revision']
    
    p svn_base_revision
    
    # svn_diff = `svn diff`
    # svn_diff_md5 = Digest::MD5.hexdigest(svn_diff)
    # 
    # data = { :svn_base_revision => svn_base_revision, :svn_diff_md5 => svn_diff_md5 }
    # File.open('tests_passed.yml', 'w') { |file| file.puts(data.to_yaml) }
  end
  
  task 'svn_commit' => 'environment' do
    # tests_passed_file = File.open('tests_passed')
    # tests_passed = YAML.load(tests_passed_file)
  end
  
end
