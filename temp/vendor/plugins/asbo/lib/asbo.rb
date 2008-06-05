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
