module Craigslist
  class Listing
    Mail.defaults {delivery_method :sendmail}
    TABLE_NAME = :listings
    attr_accessor :title, :price, :body, :url, :new_record, :id

    def fields
      {:title => @title,
       :price => @price, 
       :body  => @body, 
       :url	 => @url}
    end

    def initialize(opts = {})
      puts opts.inspect
      opts = opts.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
      @title = opts.fetch(:title) {raise "Missing a Title"}
      @price = opts.fetch(:price) {raise "Missing a Price"}
      @body  = opts.fetch(:body) {raise "Missing a Body"}
      @url 	 = opts.fetch(:url) {raise "Missing a Url"}
    end

    def new_record?
      !!@new_record
    end

    def send_mail
      mail = new_mail_with_params
      mail.deliver!
    end

    def new_mail_with_params
      mail_body = eval("\"" + File.read('./lib/body.txt') + "\"")
      Mail.new do
        from     'from@example.com'
        to       'to@example.com'
        subject  'Housing'
        body     mail_body
      end
    end

    # Class methods

    def self.find_by_url(url)
      if row = DB.get_first_row("SELECT * FROM #{TABLE_NAME} WHERE url = ?", url)
        self.new(row)
      else
        nil
      end
    end

    def self.create(opts = {})
      self.new(opts).tap do |record|
        record.new_record = true
        key_list = record.fields.keys.join(', ')
        value_blanks = Array.new(record.fields.length, '?').join(', ')
        sql = "INSERT INTO #{TABLE_NAME} (#{key_list}) VALUES (#{value_blanks})"
        DB.execute(sql, *record.fields.values)
        record.id = DB.last_insert_row_id
      end
    end

    def self.from_url(url)
      find_by_url(url) || create(parse_doc url)
    end

    private

    def self.parse_doc(url)
      doc = Craigslist::nokogiri(url)

      {:title => doc.css('h2').text,
       :price => parse_for_price(doc),
       :body  => doc.css('.userbody').text,
       :url   => url}
    end

    def self.parse_for_price(doc)
      if doc_element = doc.css('h2').text.scan(/^\$(\d+)/).first
        doc_element.first
      else
        nil
      end
    end
  end
end
