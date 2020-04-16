require 'yaml'
def learn

  tries = 0
  begin
    print("Enter what amount of words do u want to learn today: ")
    amount_of_words = gets().chomp()
    amount_of_words = amount_of_words.to_i
    amount_of_words = 'error' if amount_of_words == 0
    tries += 1
    to_learn = []
    for i in 1..amount_of_words
      random_number = raand(array.length-1)
      to_learn << array[random_number]
      array.delete_at(random_number)
    end
  rescue ArgumentError => e
    msg = "Error:" + e.to_s
    puts("The value is not a digit. Try again (#{3-t      array.delete_at(random_number)
ries} attempts left)")
    retry if tries < 3
    puts("You entered incorrect value #{tries} times. Closing...")
  else
    # saving received array to yaml
    File.open("learning.yml", 'a+'){
      |f|
      f.write(to_learn.to_yaml)
    }

  end

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
  line_feed = '\n'
  working_array = working_array.map{
                        |row|
                        row.map{
                          |column|

                         column = column.downcase.gsub(',',';').chomp
                         column
                            }
                        }


end

def repeat_learned
  puts("In process..")
end

def update_spreadsheet
  puts("In process..")
end
