namespace :analytics do
  desc "Run all analytics-related specs (requests, views, routing)"
  task test: :environment do
    files = [
      "spec/requests/analytics_spec.rb",
      "spec/views/analytics/show.html.erb_spec.rb",
      "spec/routing/analytics_routing_spec.rb"
    ]
    system("bundle", "exec", "rspec", *files, "--format", "documentation") || exit(1)
  end

  desc "Run analytics Cucumber scenarios"
  task cucumber: :environment do
    system("bundle", "exec", "cucumber", "--tags", "@analytics", "--format", "pretty") || exit(1)
  end

  desc "Run all analytics tests (RSpec + Cucumber)"
  task all: :environment do
    Rake::Task["analytics:test"].invoke
    Rake::Task["analytics:cucumber"].invoke
  end
end
