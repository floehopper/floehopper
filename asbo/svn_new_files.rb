module Asbo

  class SvnNewFiles
  
    def initialize
      svn_status = `svn status --xml`
      p svn_status
    end
  
    def to_hash
      { :svn_new_files => @svn_new_files }
    end
  
  end
  
end

p Asbo::SvnNewFiles.new.to_hash
