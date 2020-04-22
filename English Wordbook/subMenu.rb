module Learn

  def self.learn_menu
    Screen.clear
    menu = Main::Menu.new(
        'Create new list of words to learn',
        'Continue to learn already created list of words',
        'Return to main menu'
    )
    answer = menu.get_menu_choice

    case answer
    when 1 then Learn.create_new
    when 2 then Learn.continue
    when 3 then Main.menu
    end
  end

  # does not allow creating a new list
  # if there are more than 3 word lists in the study
  def self.create_check
    check_array = MyData.to_load_array($in_learning)
    check_array.length >= 2 ? false : true
  end

  def self.create_new
      if File.exist?($in_learning)
       if !(Learn.create_check)
        Screen.clear
        puts("You cannot create another list as long as\nyou already have 3 unfinished lists")
        puts("Returning to previous menu...")
        sleep(2)
        Learn.learn_menu
        return
       end
     end

      # def array to learn
      list_to_learn = [[0]]
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
        # full_list.delete_at(random_number)
      end
      # saving modified full list
      # MyData.to_save($full_list, full_list)
      # adding idicator of learning progress (must be 3 for learning complete)

      puts("New list was created, full list was modified...")
      Learn.sub_menu(list_to_learn)

  end

  def self.continue
    if !(File.exist?($in_learning))
      puts("The list o words is empty, create new first")
      puts("Redirect to new list creation...")
      sleep(2)
      Learn.create_new
      return
    end
    data = MyData.to_load_array($in_learning)
    p data[0]
    i = 0
    loop do
      Screen.clear
     puts("Choose the list of words you want to continue to study")
     puts("List ##{i+1}")
     # iterates over all words in list to print each word and translation

     data[i].each_with_index{|list, index|
       if index == 0
         puts("You have passed #{list[0]}/3")
       else
       puts("#{list[0]} ====> #{list[1]}")
       end
     }

     menu = Main::Menu.new(
         'Choose this',
         'Next',
         'Previous',
         'Go to main menu'
     )
     answer = menu.get_menu_choice

     case answer
     when 1 then data -= data[i]; MyData.to_save($in_learning, data); Learn.sub_menu(data[i]); break
     when 2 then i += 1
     when 3 then i == 0? puts("Unable to make backstep") : i -= 1 ; sleep(1)
     when 4 then Main.menu ; break
     end
   end
  end
  # generall menu for whole learning process
  def self.sub_menu(list_to_learn)
    Screen.clear
    menu = Main::Menu.new(
      "Start lesson ##{list_to_learn[0][0].to_i+1}",
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

# learning module, need to pass array of words
  module Start
    $list_to_learn = []
    # copy of list to pass it to local source after learning, no manipulations
    # with this array will be
    $copy_of_list_to_learn = []

    @@steps_for_loop = 0
    @@faults = 0
    # uploading array from local source
    @@full_list = MyData.to_load($full_list)
    # instance variable for words selection for the second exercise
    @@passed = ['test']
    # getting an iterator for exercise based on the number
    # of word remaining(passed examination)
    def self.start_learning(list_to_learn)
      $list_to_learn = list_to_learn
      $copy_of_list_to_learn = list_to_learn
      p $copy_of_list_to_learn[0][0]
      while (($list_to_learn.length != 1 ) && (@@passed != []))
        @@passed = [] if @@passed[0] == 'test'
        puts("Loop stated")
        Learn::Start.get_steps
        Learn::Start.demonstrate
        Learn::Start.picking_exercise
        Learn::Start.writting_exercise
      end
      if @@faults < $copy_of_list_to_learn.length
        puts("Congratulations, you passed this lesson.")
        puts("Progress was saved. Returning to main menu.")
        # saving and updating data in in_learning.yml
        if File.exist?($in_learning)
          in_learning = MyData.to_load_array
          in_learning = in_learning.delete($copy_of_list_to_learn)
          $copy_of_list_to_learn[0][0] += 1
          in_learning << $copy_of_list_to_learn
          MyData.to_save($in_learning, $copy_of_list_to_learn)
        else
          $copy_of_list_to_learn[0][0] += 1
          MyData.to_save($in_learning, $copy_of_list_to_learn)
        end
        # modifying full list file by excluding words that were taken for study
        full_list = MyData.to_load($full_list)
        full_list -= $copy_of_list_to_learn
        MyData.to_save($full_list, full_list)


        # MyData.to_save($in_learning)

        # if the lesson was completed 3 times => list is passed to 'learned.yml'
        # and deleted from 'in_learning.yml'
        if $copy_of_list_to_learn[0][0] == 2
          puts("You have completed learning the list of these words. ")
          puts("Saving progress... Returning to main menu")
          MyData.to_save($learned, $copy_of_list_to_learn)
          in_learning = MyData.to_load_array
          in_learning = in_learning.delete($copy_of_list_to_learn)
          MyData.to_save($in_learning, $copy_of_list_to_learn)
        end
          Main.menu
      end

    end



    def self.view_list(list_to_learn)
      Screen.clear
      puts("Here is a list of words from this lesson:")
      list_to_learn.each { |array| puts("#{array[0]} ====> #{array[1]}\n") }
      print("Press 'enter' to return back to previous menu...")
      answer = gets().chomp()
      Learn.sub_menu(list_to_learn)
    end


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
        variants << @@full_list[rand(@@full_list.length-1)][1]
      end
      return variants.shuffle
    end

    # choose correct words from the list of variants
    def self.picking_exercise

      for i in 1..@@steps_for_loop
        # Screen.clear
        variants = Learn::Start.variants_shuffle($list_to_learn[i])
        puts("Correct translation of the word '#{$list_to_learn[i][0]}' is: ")
        variants.each_with_index{|str,index|
                  print("#{index+1}) #{str}") ; index.even? ? print(" | ") : print("\n")
                }
        puts("-------------")
        printf("Your answer: ")
        answer = gets().chomp().to_i
        if variants[answer - 1] == $list_to_learn[i][1]
          puts("It is correct answer. Going next?")
          @@passed << $list_to_learn[i]
          $list_to_learn[i] = nil
          enter = gets().chomp()
          puts("next.")
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
