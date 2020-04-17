require 'yaml'
# filename for saving/loading main spreadsheet
$full_spreadsheet = 'full_spreadsheet.yml'
# filename for saving/learning array of words that are currently being learned
$learning_spreadsheet = 'learning_spreadsheet.yml'

# module for clearing terminal screen
module Screen
    def self.clear
        print "\e[2J\e[f"
    end
end

module MyData

  def self.to_load(filename)
    input_data = File.read(filename)
    input_data = YAML::load(input_data)
  end

  def self.to_save(filename, output)
    mode = 'a+' if filename == $learning_spreadsheet
    mode = 'w' if filename == $full_spreadsheet
    File.open(filename, mode){
                      |f|
                      f.write(output.to_yaml)
    }
  end

end

module Menu

  def self.main
   puts("What do you want to do?")
   puts("1. Parse your spreadsheet to local database")
   puts("2. Learn new words.")
   puts("3. Repeat learned.")
   puts("4. Update your spreadsheet by removing learned words.")
   puts("5. Exit")
   print("Your answer?: ")
   answer = gets().chomp()

   case(answer.to_i)
     when 1 ; require './parse/parse.rb'; load('./parse/parse.rb'); parse
     when 2 ; require './learn/to_learn.rb' ; load('./learn/to_learn.rb') ; Lerning.menu
     when 3 ; require './repeat/to_repeat.rb' ; repeat_learned
     when 4 ; # update_spreadsheet
     when 5 ; return
   end

  end

end

Menu.main
