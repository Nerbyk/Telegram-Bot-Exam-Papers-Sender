# frozen_string_literal: true

require 'yaml'
# file name for keeping full list of words from spreadsheet
$full_list = 'full_list.yml'
# file name for keeping list of words that u are currently studying
$in_learning = 'in_learning.yml'
# file name for keeping list of words that were learned
$learned = 'learned.yml'

# module for clearing terminal screen
module Screen
  def self.clear
    print "\e[2J\e[f"
  end
end

# module for manipulations with data
module MyData
  def self.to_load(filename)
    output_data = File.read(filename)
    output_data = YAML.safe_load(output_data)
  end

  def self.to_save(filename, output_array)
    mode = 'a+' if filename == $in_learning
    mode = 'r' if filename == $learned
    mode = 'w' if filename == $full_list
    File.open(filename, mode) do |f|
      f.write(output_array.to_yaml)
    end
  end
end

module Spreadsheet
  # parsing google spreadsheet
  def self.load_full_list
    require 'bundler'
    Bundler.require

    # Authenticate a session with your Service Account
    session = GoogleDrive::Session.from_service_account_key('client_secret.json')

    # Get the spreadsheet by its title
    spreadsheet = session.spreadsheet_by_title('Ruby voc')
    # Get the first worksheet
    worksheet = spreadsheet.worksheets.first
    # Print out the first 6 columns of each row
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
    Menu.main
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
      Screen.clear
      @menu_items.each_with_index do |item, index|
        puts("#{index + 1}. #{item}")
      end
      puts('-----------------')
      print('Select menu item: ')
      user_choice = gets.chomp.to_i
    end
  end

  def self.menu
    # Parsing spreadsheet to local source
    Spreadsheet.load_full_list unless File.exist?($full_list)
    # creates main menu with Menu class
    menu = Main::Menu.new(
      'Learn new words / Continue learning',
      'Repeat already learned words',
      'Exit'
    )
    answer = menu.get_menu_choice

    case answer
    when 1 then Learn.learn_menu
    when 2 then puts('Repeating')
    when 3 then nil
    end
  end
end

module Learn

  def self.learn_menu
    menu = Main::Menu.new(
        'Create new list of words to learn',
        'Continue to learn already created list of words',
        'Return to main menu'
    )
    answer = menu.get_menu_choice

    case answer
    when 1 then Learn.create_new
    when 2 then puts("continue")
    when 3 then Main.menu
    end
  end

  def self.create_new
      # def array to learn
      list_to_learn = []
      # loading all words to array from local source
      full_list = MyData.to_load($full_list)
      print("Enter what amount of words do u want to add to a new list: ")
      answer = gets().chomp().to_i
      if answer > 25
        puts("You can't add to list more, than 25 words")
        Learn.create_new
      end
      # getting random array of strings from full_list array
      for i in 1..answer
        random_number = rand(full_list.length-1)
        list_to_learn << full_list[random_number]
        full_list.delete_at(random_number)
      end
      # saving modified full list and learning list
      MyData.to_save($full_list, full_list)
      MyData.to_save($in_learning, list_to_learn)
      # adding idicator of learning progress (must be 3 for learning complete)
      list_to_learn.unshift(0)
      puts("New list was created, full list was modified...")
      Learn.sub_menu(list_to_learn)
  end

  # generall menu for whole learning process
  def self.sub_menu(list_to_learn)
    Screen.clear
    menu = Main::Menu.new(
      "Start lesson ##{list_to_learn[0]+1}",
      "View a list of words in a lesson",
      "Return to previous menu",
      "Return to main menu"
    )

    answer = menu.get_menu_choice

    case answer
    when 1 then Learn::Start.start_learning(list_to_learn)
    when 2 then Learn::Start.view_list(list_to_learn)
    when 3 then Learn.learn_menu
    when 4 then Main.menu
    end
  end

  module Start
    $list_to_learn = []
    $copy_of_list_to_learn = []
    def self.start_learning(list_to_learn)
      $list_to_learn = list_to_learn
      $copy_of_list_to_learn = list_to_learn

        Learn::Start.get_steps
        Learn::Start.demonstrate
        Learn::Start.picking_exercise
        Learn::Start.writting_exercise


    end

    def self.view_list(list_to_learn)
      Screen.clear
      puts("Here is a list of words from this lesson:")
      list_to_learn.each { |array| puts("#{array[0]} ====> #{array[1]}\n") }
      print("Press 'enter' to return back to previous menu...")
      answer = gets().chomp()
      Learn.sub_menu(list_to_learn)
    end

    @@steps_for_loop = 0
    @@faults = 0
    # uploading array from local source
    @@full_list = MyData.to_load($full_list)
    # instance variable for words selection for the second exercise
    @@passed = []
    # getting an iterator for exercise based on the number
    # of word remaining(passed examination)
    def self.get_steps
      $list_to_learn.length >= 5 ? @@steps_for_loop = 5 : @@steps_for_loop = $list_to_learn.length-1
    end
    # demonstration of words
    def self.demonstrate
      for i in 1..@@steps_for_loop
        Screen.clear
        puts("#{$list_to_learn[i][0]} ===> #{$list_to_learn[i][1]}")
        puts("Press enter to continue...")
        answer = gets().chomp()
      end
    end

    # gets and shuffle position of correct variant with incorrect
    # for picking exercise

    def self.variants_shuffle(correct)
      variants = [correct[1]]
      for i in 1..3
        variants << @@full_list[rand(@@full_list.length-1)[1]]
      end
      return variants.shuffle
    end

    # choose correct words from the list of variants
    def self.picking_exercise

      for i in 1..@steps_for_loop
        Screen.clear
        variants = Learn::Start.variants_shuffle($list_to_learn[i])
        puts("Correct translation of the word '#{$list_to_learn[i][0]}' is: ")
        variants.each_with_index{|str,index|
                  print("#{index+1}) #{str}") ; index.even? ? print(" | ") : print("\n")
                }
        puts("-------------")
        printf("Your answer: ")
        answer = gets().chomp().to_i
        if variants[answer] == $list_to_learn[i][1]
          puts("It is correct answer. Going next?")
          @@passed << $list_to_learn[i]
          $list_to_learn = nil
          enter = gets().chomp()
        else
          puts("It's wrong answer. \n#{$list_to_learn[i][0]} ===> #{$list_to_learn[i][1]}")
          @@faults += 1
          puts("Faults = #{@@faults}")
          enter = gets().chomp()
        end
      end
     $list_to_learn.compact!
    end

    # write the word appropriate to the translation
    def self.writting_exercise
      @@passed.shuffle
      if @@passed.length >= 3
        for i in 0..@@passed.length-3
          Screen.clear
          puts("Write the translation of the word '#{@@passed[i][1]}' ")
          print("Your answer: ")
          answer = gets().chomp()
          if answer == @@passed[i][0]
            puts("It's correct answer. Going next?(press enter)")
            @@passed[i] = nil
            enter = gets().chomp()
          else
            puts("It's wrong answer.\n#{@@passed[i][0]} ===> #{@@passed[i][1]}")
            @@faults += 1
            puts("Faults = #{@@faults}")
            enter = gets().chomp()
          end
        end
      end
      @@passed.compact!
    end

  end


end

module Repeat
end


# starts program
Main.menu
