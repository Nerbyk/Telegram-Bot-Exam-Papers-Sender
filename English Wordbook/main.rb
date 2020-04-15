 require 'yaml'
# filename for saving/loading main spreadsheet
$full_spreadsheet = 'full_spreadsheet.yml'
# filename for saving/learning array of words that are currently being learned
$learning_spreadsheet = 'learning_spreadsheet.yml'

def loadDB(filename)
  input_data = File.read(filename)
  input_data = YAML::load(input_data)
end

def saveDB(filename, outputdata)
  mode = 'a+' if filename == $learning_spreadsheet
  mode = 'w' if filename == $full_spreadsheet
  File.open(filename, mode){
                    |f|
                    f.write(outputdata.to_yaml)
  }
end


 def learn
   if File.exist?($full_spreadsheet)
    array = loadDB($full_spreadsheet)
   else
     puts("The file #{$full_spreadsheet} cannot be found.")
     return
   end


   tries = 0
   begin
     print("Enter what amount of words do u want to learn today: ")
     amount_of_words = gets().chomp()
     amount_of_words = amount_of_words.to_i
     amount_of_words = 'error' if amount_of_words == 0
     tries += 1
     to_learn = []
     for i in 1..amount_of_words
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

   puts("What exercise do you want to start with?")
   puts("1. Choosing the right option")
   puts("2. Translation from Russian into English (keyboard input)")
   puts("3. Translation from English into Russian (keyboard input)")
   puts("4. View a list of words")
   answer = gets().chomp()
   case(answer.to_i)
   when 1 then


 end

 def parse
   require 'bundler'
   Bundler.require

   # Authenticate a session with your Service Account
   session = GoogleDrive::Session.from_service_account_key("client_secret.json")

   # Get the spreadsheet by its title
   spreadsheet = session.spreadsheet_by_title("Ruby voc")
   # Get the first worksheet
   worksheet = spreadsheet.worksheets.first
   # Print out the first 6 columns of each row
   working_array = worksheet.rows
   working_array = working_array.map{
                         |row|
                         row.map{
                           |column|

                          column = column.downcase.gsub(',',';').chomp
                          column
                             }
                         }
   # saving to yaml
   saveDB($full_spreadsheet, working_array)
     puts("Data was successfully saved to a local source. #{Dir.glob($full_spreadsheet)}")
 end

 def repeat_learned
   puts("In process..")
 end

 def update_spreadsheet
   puts("In process..")
 end


 puts("What do you want to do?")
 puts("1. Parse your spreadsheet to local database")
 puts("2. Learn new words.")
 puts("3. Repeat learned.")
 puts("4. Update your spreadsheet by removing learned words.")
 puts("5. Exit")
 print("Your answer?: ")
 answer = gets()
 case(answer.to_i)
 when 1 ; parse
 when 2 ; learn
 when 3 ; repeat_learned
 when 4 ; update_spreadsheet
 end
