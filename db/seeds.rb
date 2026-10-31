require "csv"


# Lessons, questions and "Você sabia?" texts -------------------------
# One idempotent call: safe to run again, it creates what is missing and
# updates the texts from db/data/*.csv (see lib/content_sync.rb)
puts "-=-=-=-=- SYNCING LESSONS, QUESTIONS AND INFORMATIONS -=-=-=-=-"
require Rails.root.join("lib/content_sync")
puts "#{ContentSync.call(log: ->(message) { puts message })} records created or updated"
# -------------------------------------------------------------------

# Creating Users ------------------------------------------------
puts "-=-=-=-=- CREATING USERS -=-=-=-=-"
users_path = "db/data/Mani - users_starter.csv"
CSV.foreach(users_path, headers: :first_row) do |row|
  if User.find_by(username: row['username']).nil?
    User.create!(email: row['email'],
                 username: row['username'],
                 password: row['password'],
                 birthday: row['birthday'],
                 xp: row['xp'])
    puts "Username created, username: #{User.last.username}"
  end
end
# -------------------------------------------------------------------
