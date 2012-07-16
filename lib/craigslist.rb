require 'nokogiri'
require 'open-uri'
require 'mail'
require 'date'
require 'sqlite3'

require_relative './db.rb'
require_relative './listing.rb'

DB.database_file = ENV.fetch('DATABASE') { 'db/development.db' }

module Craigslist
  def self.fetch(url)
    open(url)
  end

  def self.nokogiri(url)
    Nokogiri::HTML(fetch(url))
  end

  class Query
    def initialize(url)
      @url = url
    end

    def each_listing
      listing_urls.each do |url|
        yield Listing.from_url(url)
      end
    end

    def listing_urls
      Craigslist::nokogiri(@url).css('p.row a').map { |link| link['href'] }
    end
  end
end

Craigslist::Query.new(ARGV.first || 'http://sfbay.craigslist.org/apa').each_listing do |listing|
  puts "#{listing.title}"
  listing.send_mail if listing.new_record
end
