require 'rake/rdoctask'

Rake::RDocTask.new(:rdoc => 'rdoc',
               :clobber_rdoc => 'rdoc:clean',
               :rerdoc => 'rdoc:force') do |rd|
  #rd.rdoc_dir = 'public_html/rdoc'
  rd.main = 'README'
  rd.rdoc_files.include('README', 'lib')
  #rd.options << '-c UTF-8'
end
