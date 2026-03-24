# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Seed a super admin user
User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.first_name = "Super"
  u.last_name = "Admin"
  u.password = "password"
end.then do |u|
  u.update!(super_admin: true) unless u.super_admin?
end

# Seed a demo client account with an admin and trainers
acme = Client.find_or_create_by!(name: "Acme Corp")

User.find_or_create_by!(email_address: "admin@acme.com") do |u|
  u.first_name = "Dave"
  u.last_name = "Brown"
  u.password = "password"
  u.client = acme
  u.client_admin = true
end

trainers = [ { email: "trainer1@acme.com", first: "Alice", last: "Smith", status: :active },
             { email: "trainer2@acme.com", first: "Bob", last: "Jones", status: :inactive },
             { email: "trainer3@acme.com", first: "Carol", last: "White", status: :pending_password_change } ].map do |t|
  User.find_or_create_by!(email_address: t[:email]) do |u|
    u.first_name = t[:first]
    u.last_name = t[:last]
    u.password = "password"
    u.client = acme
    u.status = t[:status]
  end
end

# Seed master trainings for the demo account
alice = trainers.first
[ { title: "Safety Training", description: "Comprehensive safety training program covering workplace hazards, emergency procedures, and protective equipment." },
  { title: "Onboarding", description: "New employee onboarding program introducing company culture, policies, and day-to-day workflows." },
  { title: "Strength & Conditioning", description: "Progressive strength and conditioning program designed to build functional fitness and athletic performance." } ].each do |mt|
  MasterTraining.find_or_create_by!(title: mt[:title], client: acme) do |m|
    m.trainer = alice
    m.description = mt[:description]
  end
end
