# frozen_string_literal: true

require 'yaml'

# file name for keeping full list of words from spreadsheet
$full_list = 'full_list.yml'
# file name for keeping list of words that u are currently studying
$in_learning = 'in_learning.yml'
# file name for keeping list of words that were learned
$learned = 'learned.yml'

module MyData

  def self.to_save(filename, output_array)
    mode = 'r' if filename == $learned
    mode = 'w' if filename == $full_list || filename == $in_learning
    File.open(filename, mode) do |f|
      f.write(output_array.to_yaml)
    end
  end
  # loads first list in yaml file
  def self.to_load(filename)
    output_data = File.read(filename)
    output_data = YAML.safe_load(output_data)
  end
  # loads whole yml and passes it to array to return
  def self.to_load_array(filename)
    return_arr = []
    File.open(filename){|f|
    YAML.load_stream(f){|doc|
      return_arr << doc
      }
    }
    return_arr
  end
end



# module for clearing terminal screen
module Screen
  def self.clear
    print "\e[2J\e[f"
  end
end

# module for manipulations with data
module Spreadsheet

  def self.login
    require 'bundler'
    Bundler.require

    # Authenticate a session with your Service Account
    session = GoogleDrive::Session.from_service_account_key('client_secret.json')

    # Get the spreadsheet by its title
    spreadsheet = session.spreadsheet_by_title('Ruby voc')
    # Get the first worksheet
    worksheet = spreadsheet.worksheets.first
  end


  # parsing google spreadsheet
  def self.load_full_list
    worksheet = Spreadsheet.login

    working_array = worksheet.rows
    working_array = working_array.map do |row|
      row.map do |column|
        column = column.downcase.gsub(',', ';').chomp
        column
      end
    end
    # saving to yaml
    MyData.to_save($full_list, working_array)
    puts("Data was successfully saved to a local source. #{Dir.glob($full_list)}")
    puts('Returning to main menu...')
    sleep(3)
    Screen.clear
    Main.menu
  end


  def self.insert_learned_list
    worksheet = Spreadsheet.login
  end
end


module Main
  # class for menu generation
  class Menu
    attr_reader :length_quit

    def initialize(*menu_items)
      @menu_items = menu_items
      @length_quit = menu_items.length
    end

    # print menu
    def get_menu_choice

      @menu_items.each_with_index do |item, index|
        puts("#{index + 1}. #{item}")
      end
      puts('-----------------')
      print('Select menu item: ')
      user_choice = gets.chomp.to_i
    end
  end

  def self.menu
    # Parsing spreadsheet to local source if it is first start
    Spreadsheet.load_full_list unless File.exist?($full_list)
    # creates main menu with Menu class
    menu = Main::Menu.new(
      'Learn new words / Continue learning',
      'Repeat already learned words',
      'Exit'
    )
    answer = menu.get_menu_choice

    case answer
    when 1 then require './subMenu.rb' ; load('./subMenu.rb') ; Learn.learn_menu
    when 2 then puts('Repeating')
    when 3 then return
    end
  end
end

Main.menu
