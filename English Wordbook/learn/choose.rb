$to_learn = [["consistently", "последовательно"], ["lack", "отсутствие"], ["distinction", "различие"], ["explicitly", "ясно; точно; открыто"], ["deliberately", "сознательно"], ["inspection", "проверка"], ["sequence", "последовательность"]]
require 'yaml'
# module for clearing terminal screen
# To be completely honest with yourself in learning process
module Screen
    def self.clear
        print "\e[2J\e[f"
    end
end

$input_data = File.read("full_spreadsheet.yml")
$input_data = YAML::load($input_data)
$faults = 0
# removing your exersize words from main list of all words
$input_data = $input_data - $to_learn

$steps_for_loop = 0

def get_right_amount_of_laps
  $to_learn.length >= 5 ? $steps_for_loop = 4 : $steps_for_loop = $to_learn.length - 1
end

# loop for 5 words to learn if in array more
# then 5 words
def demonstate

  for i in 0..$steps_for_loop
     Screen.clear
     puts("#{$to_learn[i][0]} ===> #{$to_learn[i][1]}")
     puts("Press enter to continue...")
     answer = gets().chomp()
  end
end


# mixing variants of answer in array
def random_generate(correct_ans)

    array_of_variants = [correct_ans[1]]
    for i in 1..3
      array_of_variants << $input_data[rand($input_data.length-1)][1]
    end
    return array_of_variants.shuffle
end

def correct_answer_check


    for i in 0..$steps_for_loop
      Screen.clear
      answers = random_generate($to_learn[i])
      puts("correct translation of the word '#{$to_learn[i][0]}' is: ")
      answers.each_with_index{|str, index| print("#{index+1}) #{str}") ; index.even? ? print(" | ") : print("\n") }
      puts("-----------")
      print("Your choice: ")
      answer = gets().chomp()
      if answers[(answer.to_i)-1] == $to_learn[i][1]
        puts("It is correct answer. Going next?")

        $to_learn[i] = nil

      else
        puts("It's wrong answer. \n#{$to_learn[i][0]} ===> #{$to_learn[i][1]}")
        $faults += 1
        puts("Faults = #{$faults}")
        answer = gets()
      end
   end
   $to_learn.compact!

end

def start_loop
  while($to_learn != [])
    $to_learn.shuffle!
    get_right_amount_of_laps
    demonstate
    correct_answer_check
  end
  $to_learn = [["consistently", "последовательно"], ["lack", "отсутствие"], ["distinction", "различие"], ["explicitly", "ясно; точно; открыто"], ["deliberately", "сознательно"], ["inspection", "проверка"], ["sequence", "последовательность"]]
  final_exam = $faults.to_f / $to_learn.length.to_f
  puts("final exam = #{final_exam}")
    if ( final_exam > 1 )
      puts("You've done #{$faults} mistakes (#{$faults+$to_learn.length}/#{$to_learn.length}). You must re-run the task")
      $to_learn = [["consistently", "последовательно"], ["lack", "отсутствие"], ["distinction", "различие"], ["explicitly", "ясно; точно; открыто"], ["deliberately", "сознательно"], ["inspection", "проверка"], ["sequence", "последовательность"]]
      answer = gets().chomp
      start_loop
    end
end

start_loop
