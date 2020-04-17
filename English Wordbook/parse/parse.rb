include MyData
include Menu
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
  MyData.to_save($full_spreadsheet, working_array)
    puts("Data was successfully saved to a local source. #{Dir.glob($full_spreadsheet)}")
    puts("Returning to main menu...")
    sleep(5)
    Menu.main
end
