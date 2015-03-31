require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--lint']
end

require "gem_publisher"
task :publish_gem do
  gem = GemPublisher.publish_if_updated("ubuntu_unused_kernels.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end

task :default => [:rubocop, :spec]
