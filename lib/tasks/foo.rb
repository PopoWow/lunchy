if FileTest.exists?('weekly_menu.json')
  bar = "hi there"
else
  bar = "foo"
end

puts bar