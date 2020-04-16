
def learn_main

  if File.exist?($full_spreadsheet)
   array = loadDB($full_spreadsheet)
  else
    puts("The file #{$full_spreadsheet} cannot be found.")
    puts("You must choose First option in previous menu at the beginning.")
    puts("Returning to main menu...")
    sleep(5)
    main_menu
    return
  end
answer = nil
  while answer != 'EXIT'
    tries = 0
    begin
      print("Enter what amount of words do u want to learn today: ")
      answer = gets().chomp()
      answer = answer.to_i
      answer = 'error' if answer == 0
      tries += 1
      to_learn = []
      for i in 1..answer
        random_number = rand(array.length-1)
        to_learn << array[random_number]
        array.delete_at(random_number)
      end
    rescue ArgumentError => e
      msg = "Error:" + e.to_s
      puts("The value is not a digit. Try again (#{3-tries} attempts left)")
      retry if tries < 3
      puts("You entered incorrect value #{tries} times. Closing...")
    else
      # saving received array to yaml
      saveDB($learning_spreadsheet, to_learn)
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
    when 1 ; choose_right_exersice(to_learn)
    when 2 ; puts("In process")
    when 3 ; puts("In process")
    when 4 ;
    end

  end

end

def choose_right_exersice(to_learn)
  p(to_learn )
end
