
begin
  require 'webby'
rescue LoadError
  require 'rubygems'
  require 'webby'
end

SITE = Webby.site

SITE.host = 'floehopper@www.hannahsmithson.org'
SITE.remote_dir = '/var/www/www.hannahsmithson.org/'

# Load the other rake files in the tasks folder
Dir.glob('tasks/*.rake').sort.each {|fn| import fn}

# EOF
