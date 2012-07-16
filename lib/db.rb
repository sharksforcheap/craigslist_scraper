module DB
  class Error < StandardError;end

  class ConnectionError  < DB::Error;end
  class UnknownAttribute < DB::Error;end
  class RecordNotFound   < DB::Error;end

  def self.reset!
    @database = nil
  end

  def self.database_file=(database)
    @database = SQLite3::Database.new(database)

    # This configures SQLite to return, e.g.,
    # DateTime objects instead of strings that then need to be parsed
    @database.type_translation = true

    # return results as an array of hashes rather than an array of arrays, e.g.,
    #   [{'id' => 1, 'name' => 'Jesse'}, {'id' => 2, 'name' => 'Bob'}] vs.
    #   [[1, 'Jesse'], [2, 'Bob']]
    #
    # See: http://sqlite-ruby.rubyforge.org/sqlite3/faq.html#538670736
    @database.results_as_hash = true

    # If you don't see why this is advantageous, then riddle me this:
    #
    # You see this code
    #   results = @database.execute("SELECT * FROM some_table")
    #   results.each do |result|
    #     puts result[1]
    #   end
    #
    # What kind of thing is getting printed out to the console?
    # How would you find out?
    # How do you know what order the fields are returned in
    # when you do SELECT * FROM rather than, e.g., SELECT id, name FROM?
    #
    # Now consider:
    #   results = @database.execute("SELECT * FROM some_table")
    #   results.each do |result|
    #     puts result['name']
    #   end
    #
    # Which is more understandable?
    #
    # Do you ever actually care what "order" the database returns the fields in,
    # except for display or reporting purposes?
  end


  # See http://www.ruby-doc.org/core-1.9.3/BasicObject.html#method-i-method_missing
  # If an object defines method_missing, Ruby will call it
  # as a "measure of last resort" if the method is otherwise undefined
  #
  # This is hard to wrap your head around unless you think of 
  # method calls as messages, and objects as recipients of those messages.
  #
  # "methods" are then like mailboxes.  If you define SomeClass#foo, then 
  # every time you call SomeClass.new.foo the message gets sent to 
  # the "def foo(...);end" mailbox
  #
  # method_missing says, "If nothing else wants to deal with this message, I will"
  # like some kind of lost and found
  #
  # See also http://ruby-doc.org/core-1.9.3/Object.html#method-i-send
  # for how Object#send works

  def self.method_missing(method, *args)
    if @database
      @database.send(method, *args)
    else
      raise ConnectionError.new('No valid database connection.')
    end
  end

  # Ideally, an object knows how to "sanitize" itself
  # However, augmenting core classes is also a hack
  def self.sanitize(input)
    case input
    when Time, DateTime, Date
      input.strftime('%FT%T%:z')
    else
      input
    end
  end
end