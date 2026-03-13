Given('the following equipment exists:') do |table|
  table.hashes.each do |row|
    Equipment.create!(
      name: row['name'],
      department: row['department'],
      quantity: row['quantity'].to_i
    )
  end
end

When('I visit the equipment page') do
  visit equipment_index_path
end

Then('the available count for {string} should show {int}') do |name, count|
  expect(page).to have_content("#{name} - available: #{count}")
end