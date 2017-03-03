require 'artii'
require 'date'
require "terminal-table"
require 'colorize'
require 'csv'

#App Start up
a = Artii::Base.new :font => 'univers'
puts a.asciify('Active Plan')


def clear
  system "clear"
end

#Sign-in method (used by display_menu)
def sign_in
  puts "Username: "
  print "> "
  username = gets.chomp
  clear

  puts "Password: "
  print "> "
  password = gets.chomp
  clear

  sleep 1

  if password == "password" #smart password
    puts "You're logged in!"
    signin_display_menu
  else
    puts "Pasword Invalid!"
    puts "Please enter the correct password!"
    password1 = gets.chomp
    clear

    sleep 1

      if password1 == "password" #smart password
        puts "You're logged in!"
        signin_display_menu
      else
        puts "Sorry, we are putting you back to main menu!"
        display_menu
      end

    end

  # display_menu

end
#End of Sign-in method (used by display_menu)

#Register method (used by display_menu)
def register
  puts "Create Username: "
  print "> "
  register_username = gets.chomp
  clear

  puts "Create Password: "
  print "> "
  register_password = gets.chomp
  clear

  sleep 1

  if register_password != ""
    puts "You've registered successfully'!"
    puts "Get Starter Now!"
    signin_display_menu
  else
    puts "Please enter something!"
    register_password1 = gets.chomp
    clear

    sleep 1

    if register_password1 != "" #no empty password
      puts "Your password is accepted!"
      signin_display_menu
    else
      puts "Sorry, we are putting you back to main menu!"
      display_menu
    end
  end

  # display_menu

end
#End of Register method (used by display_menu)

#Display Menu method
def display_menu

  option = nil
  while option != "3" do
  puts "You are in ActivePlan App"
  puts "1. Sign-in"
  puts "2. Register as New User"
  puts "3. Quit"
  option = gets.chomp

  clear

  case option

  when "1"
    sign_in
  when "2"
    register
  when "3"
    exit
  end
  end
end
#End of Display Menu method

#Delare a blank array outside of the loop in global environment as it allows looping and task extraction happen at same time
$task_list = []

class Task
  # @@task_count is a class variable shared by Task and every subclass.
  # When you instantiate a Task or any kind of Task, such as a swimming,
  # the count increases.
  @@task_count = 0
  @@current_time = DateTime.now

  attr_accessor :id, :last_modified, :task_description, :start_time, :end_time, :location,
  :status

  def initialize(task_description, start_time, end_time, location, last_modified = "false", id = 0, status = false)
    if id == 0
      @id = self.class.task_count += 1
    else
      @id = id
    end
    if last_modified == "false"
      @last_modified = self.class.current_time.strftime "%d/%m/%Y %H:%M"
    else
      @last_modified = last_modified
    end
    @task_description = task_description
    @start_time = start_time
    @end_time = end_time
    @location = location
    # @status = status

    # puts "You are in Task Input Section"

  end

  ######EXCEL Output Part##########################
  # Initialize from CSV::Row
  def self.from_csv_row(row)

    self.new(
      row['task_description'],
      row['start_time'],
      row['end_time'],
      row['location'],
      row['last_modified'],
      row['task_id']
    )

  end

  HEADERS = ['task_id', 'task_description', 'start_time', 'end_time', 'location', 'last_modified']

  # Convert to CSV::Row
  def to_csv_row
    CSV::Row.new(HEADERS, [id, task_description, start_time, end_time, location, last_modified])
  end
  ######End of EXCEL Output Part##########################


  #Declare reader class method for task_count
  def self.task_count
    @@task_count
  end

  #Declare writer class method for task_count
  def self.task_count=(value)
    @@task_count = value
  end

  #Declare reader class method for current_time
  def self.current_time
    @@current_time
  end

  #Declare writer class method for current_time
  def self.current_time=(value)
    @@current_time = value
  end

  # Declare a method for user_input
  def Task.ask_for_task_detail

    #First Question
    puts "What task would you like to insert?"
    print "> "
    task_description = gets.chomp

    #Second Question
    puts "What time would you like to start the task?"
    print "> "
    start_time = gets.chomp

    #Third Question
    puts "What time would you like to end the task?"
    print "> "
    end_time = gets.chomp

    #Fourth Question
    puts "Where would you do the task?"
    print "> "
    location = gets.chomp

    #Declare a return function with same argument at the INITIALIZE method
    return new(task_description, start_time, end_time, location)

  end #End of Task.ask_for_task method within class Task

  def Task.ask_for_task

    #Create a startup condition for the loop
    next_task = true
    while next_task == true do

      #Create a startup condition for nested if statement
      next_task_inner = true

      #Go thru the Task.ask_for_task method
      user_task = Task.ask_for_task_detail
      puts "You have inserted a task."

      puts "Your task summary"
      puts "Your tasks is #{user_task.task_description}."
      puts "Your tasks starts at #{user_task.start_time} and ends at #{user_task.start_time}."
      puts "The location will be at #{user_task.location}."

      puts "Please review the following table for details entered!"

      #Collect all user input into a blank array
      $task_list << user_task
      # update maxId
      writeMaxIDIntoFile(Task.task_count)

      CSV.open('test.csv', 'a+', {force_quotes: true}) do |csv|
        csv << HEADERS if csv.count.eql? 0 # csv.count method gives number of lines in file if zero insert headers
        csv << user_task.to_csv_row
      end



      #Pass task_list as param for display task function
      Task.display_tasks($task_list)

      #Ask user if they want to insert more task
      puts "Do you want to insert another task? (Yes/No)"
      another_task = gets.chomp.capitalize
      if another_task == "No"
        next_task == false

        #To break next_task loop if user enter "No"
        break

      elsif another_task == "Yes"
        puts "You have returned to insert another task."

      else another_task != "Yes" || "No"
        puts "I don't understand, type 'No' to terminate or else you will be asked to insert new task."
        try_again = gets.chomp.capitalize
          if try_again == "No"
            next_task == false

            #To break next_task loop if user enter "No"
            break

          elsif try_again == "Yes"
            puts "You have returned to insert another task."

          else

            Task.ask_for_task

          end
          #End of Nested if statement

      end
      #End of if statement

    end
    #End of While loop
  end

  # Display an array of tasks in a table (This table will only displayed when user had finished entering all tasks)
  def Task.display_tasks(task_list)
    rows = []

    #To extracct each single task that user had entered in one session
    task_list.each do |task|
      rows << [task.id, task.task_description, task.start_time, task.end_time, task.location, task.last_modified]
    end

    #List all details entered into a table
    table = Terminal::Table.new :title => "Your Task Lists", headings: ['Task Id', 'Task Description', 'Start Time', 'End Time', 'Location', 'Last Modified'], rows: rows, :style => {:width => 120, :all_separators => true}
    puts table

  end #End of Task.display_tasks_for_task method within class Task

end # End of class Task


#Display Sign_in Display method
def signin_display_menu

  #initialize task objects from csv file
  initialize_app


  puts "You are Logged in Now"
  signin_option = nil

  while signin_option != "4" do

  puts "1. Start Inserting Your Task"
  puts "2. Review Your Task Lists"
  puts "3. Personal Settings"
  puts "4. Return to Main Menu"
  signin_option = gets.chomp

  clear

  case signin_option

  when "1"
    Task.ask_for_task
  when "2"
    Task.display_tasks($task_list)
  when "3"
    puts "Sorry, this feature is not available yet"
    puts "We will direct you back to submenu"
    signin_display_menu
end
  end
end
#End of Display Sign_in Display method


def initialize_app
  CSV.foreach('test.csv', headers: true) do |row|

  # Convert from CSV::Row to Person instance

  task = Task.from_csv_row(row)
  # Display first and last name
  $task_list.push(task)
  end

  Task.task_count = getMaxIdFromFile
end

def getMaxIdFromFile
  # file = File.new("maxId.txt", "r")
//# TODO:
  lines = File.read("maxId.txt").to_i
  # Get the first line
  maxID = lines

  return maxID
end

def writeMaxIDIntoFile(maxId)
  File.open("maxId.txt", "w") do |f|
      f.write(maxId)
  end
end

display_menu






# puts "Give your file a name"
# filename = gets.chomp
#
# #Create the new file and adds the .txt file type extension
# opened_file = File.new(filename + '.txt', 'w+')
#
# # puts "write in a sentence to save to your file '#{filename}'"
# # sentence = gets.chomp
#
# #Write sentence string to the file
# opened_file.write()
#
# opened_file.close
