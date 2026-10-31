namespace :content do
  desc "Update questions and informations in the database from the starter CSVs in db/data"
  task sync: :environment do
    require Rails.root.join("lib/content_sync")
    changed = ContentSync.call(log: ->(message) { puts message })
    puts "#{changed} records updated"
  end
end
