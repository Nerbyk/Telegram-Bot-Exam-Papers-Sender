

# array for words to learn
$to_learn = []
# a copy of previous var for saving, no manipulations with it
$to_learn_log = []

module Lerning
  def self.menu

    if File.exist?($full_spreadsheet)
     array = MyData.to_load($full_spreadsheet)
    else
      puts("The file #{$full_spreadsheet} cannot be found.")
      puts("You must choose First option in previous menu at the beginning.")
      puts("Returning to main menu...")
      sleep(5)
      Menu.main
      return
    end

   answer = nil
    while answer != 'EXIT'
      if $to_learn == [] # 0 if no one exersize was passed, trigger.
        $to_learn = [[0]]
        tries = 0
        begin
          print("Enter what amount of words do u want to learn today: ")
          answer = gets().chomp()
          answer = answer.to_i
          answer = 'error' if answer == 0
          tries += 1
          for i in 1..answer
            random_number = rand(array.length-1)
            $to_learn << array[random_number]
            array.delete_at(random_number)
          end
        rescue ArgumentError => e
          msg = "Error:" + e.to_s
          puts("The value is not a digit. Try again (#{3-tries} attempts left)")
          retry if tries < 3
          puts("You entered incorrect value #{tries} times. Closing...")
          return
        else
          # saving received array to yaml
          $to_learn_log = $to_learn
          MyData.to_save($learning_spreadsheet, $to_learn)
        end
      end
      puts("----\nYou can leave the program in any moment by typing 'EXIT'.")
      puts("But in this case the progress of exersize won't be saved to local database.\n----")


      puts("What exercise do you want to start with?")
      puts("1. Choosing the right option")
      puts("2. Translation from Russian into English (keyboard input)")
      puts("3. Translation from English into Russian (keyboard input)")
      puts("4. View a list of words")
      answer = gets().chomp()
      case(answer.to_i)
      when 1 ; self.start_picking
      when 2 ; puts("In process")
      when 3 ; puts("In process")
      when 4 ; puts $to_learn ; self.menu
      end

    end

  end

  module Picking

    @@steps_for_loop = 0
    @@faults = 0
    # upload array of full_spreadsheet.yml
    @@whole_list = MyData.to_load($full_spreadsheet)
    # removing your exersize words from main list of all words
    @@whole_list -= $to_learn
    # getting an iterator for exersize based on the number
    # of word remaining(passed examination)
    def self.get_steps
      $to_learn.length >= 5 ? @@steps_for_loop = 5 : @@steps_for_loop = $to_learn.length-1
    end
    # demonstration of words? which will be learned next
    def self.demonstrate

      for i in 1..@@steps_for_loop
        Screen.clear
        puts("#{$to_learn[i][0]} ====> #{$to_learn[i][1]}")
        puts("Press enter to continue...")
        answer = gets().chomp()
      end
    end

    # gets and shuffle position of correct variant with incorrect
    def self.variants_shuffle(correct)
      variants = [correct[1]]
      for i in 1..3
        variants << @@whole_list[rand(@@whole_list.length-1)][1]
      end
      return variants.shuffle
    end

    # exersize in loop, need to choose one correct from 4
    def self.exersize

      for i in 1..@@steps_for_loop

        Screen.clear
        variants = variants_shuffle($to_learn[i])
        puts("Correct translation of the word '#{$to_learn[i][0]}' is: ")
        variants.each_with_index{
                      |str, index|
                        print("#{index+1}) #{str}") ; index.even? ? print(" | ") : print("\n")
        }
        puts("-----------")
        print("Your choice: ")
        answer = gets().chomp()
        if variants[(answer.to_i)-1] == $to_learn[i][1]
          puts("It is correct answer. Going next?")
          $to_learn[i] = nil
        else
          puts("It's wrong answer. \n#{$to_learn[i][0]} ===> #{$to_learn[i][1]}")
          @@faults += 1
          puts("Faults = #{@@faults}")
          answer = gets().chomp()
       end
     end
     $to_learn.compact!

    end

  end

  def self.start_picking
    p $to_learn_log
    while($to_learn != [[0]])
      $to_learn[1..$to_learn.length].shuffle!
      Lerning::Picking.get_steps
      Lerning::Picking.demonstrate
      Lerning::Picking.exersize
    end
    include Picking
    if @@faults > $to_learn_log.length
      puts("You've done to much mistakes. Re-run exercise.")
      $to_learn = $to_learn_log
      self.start_picking
    else
      $to_learn_log[0][0] += 1
      puts("Congratulations, u passed this exercise. Need to finish other #{3-$to_learn_log[0][0]}")


      Menu.main
    end
  end

  end
