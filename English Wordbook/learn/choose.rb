$to_learn = [["consistently", "последовательно"], ["lack", "отсутствие"], ["distinction", "различие"], ["explicitly", "ясно; точно; открыто"], ["deliberately", "сознательно"]]
require 'yaml'
# module for clearing terminal screen
# To be completely honest with yourself in learning process
module Screen
    def self.clear
        print "\e[2J\e[f"
    end
end

input_data = File.read("full_spreadsheet.yml")
input_data = YAML::load(input_data)

# removing your exersize words from main list of all words
input_data = input_data - $to_learn
p(input_data)
# loop for 5 words to learn if in array more
# then 5 words
def demonstate
 if $to_learn.length >= 5
   for i in 0..4
     puts("#{$to_learn[i][0]} ===> #{$to_learn[i][1]}")
     puts("Press enter to continue...")
     answer = gets().chomp()
     Screen.clear
   end
 end
end

# here we have only one right option
# others are taken from spreadsheet in random way
# exept for ones we took for learning
def correct_answer_check




end












demonstate
