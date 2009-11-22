require 'rake'
require 'spec/rake/spectask'

task :default => [:run]

desc 'Run application'
task :run do
  `ruby localiza.rb`
end

desc 'Run all tests'
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_files = FileList['spec/*.rb']
  t.spec_opts = ["--format", "nested", "--color"]
  t.fail_on_error = false
end
#`spec spec/* --format nested --color`
