require 'rubygems'
require 'rake'

Rake::Task['test:units'].enhance do
  Asbo::tests_passed('test:units')
end

Rake::Task['test:functionals'].enhance do
  Asbo::tests_passed('test:functionals')
end

Rake::Task['test:integration'].enhance do
  Asbo::tests_passed('test:integration')
end

module Asbo
  
  class << self

    def tests_passed(task_name)
      abort "Warning: No test task name specified" if task_name.empty?
  
      FileUtils.mkdir_p(File.join('tmp', 'asbo'))
      data = { 'svn_base_revision' => Asbo::svn_base_revision, 'svn_diff_md5' => Asbo::svn_diff_md5 }
      filename = File.join('tmp', 'asbo', "#{task_name.gsub(/:/, '-')}.yml")
      File.open(filename, 'w') { |file| file.puts(data.to_yaml) }
    end

    def svn_base_revision
      svn_log = `svn log --revision BASE --xml`
      abort "Warning: unable to execute 'svn log'." unless $?.success?
      require 'rexml/document'
      document = REXML::Document.new(svn_log)
      Integer(document.elements['/log/logentry'].attributes['revision'])
    end

    def svn_diff_md5
      svn_diff = `svn diff`
      abort "Warning: unable to execute 'svn diff'." unless $?.success?
      require 'digest/md5'
      Digest::MD5.hexdigest(svn_diff)
    end
    
  end

end

namespace 'asbo' do

  task 'commit' do
    require 'yaml'
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
    
    puts `svn commit`
    
    Dir.glob(File.join('tmp', 'asbo', '*.yml')).each do |filename|
      working_set = YAML.load(File.open(filename))
      working_set['svn_diff_md5'] = Asbo::svn_diff_md5
      File.open(filename, 'w') { |file| file.puts(working_set.to_yaml) }
    end
  end
  
end
