

require 'sqlite3'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :user_details do
  primary_key :id
  String :name
  String :link
  String :subjects
  String :image
  String :status
end

user_details = DB[:user_details]

user_details.insert(name: 'name', link: 'vk.com')
puts("#{user_details.count}")
