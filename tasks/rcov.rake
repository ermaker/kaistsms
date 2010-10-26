require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :rcov do |t|
  t.rcov = true
  t.rcov_opts = '-Ilib --charset euc-kr -t -x ^spec'
end
