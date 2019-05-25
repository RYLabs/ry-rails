User.create!(
  first_name: FFaker::Name.first_name,
  last_name: FFaker::Name.last_name,
  email: "user@example.com",
  password: "password"
)