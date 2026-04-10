desc "Reset the database and reseed demo data"
task reset: :environment do
  Rake::Task["db:reset"].invoke
end
