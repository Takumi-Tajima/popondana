require 'httparty'

class RakutenBooksApi
  include HTTParty
  base_uri 'https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404'

  def initialize
    @options = {
      query: {
        applicationId: ENV['RAKUTEN_APPLICATION_ID'],
        format: 'json',
        hits: 20
      }
    }
  end

  def search_by_title(title)
    return [] if title.blank?

    @options[:query][:title] = title
    Rails.logger.info "Rakuten API Request: #{@options}"
    response = self.class.get('/', @options)
    
    Rails.logger.info "Rakuten API Response: #{response.code} - #{response.body}"
    
    if response.success?
      result = parse_response(response)
      Rails.logger.info "Parsed result: #{result.size} books found"
      result
    else
      Rails.logger.error "Rakuten API error: #{response.code} - #{response.message}"
      Rails.logger.error "Response body: #{response.body}"
      []
    end
  rescue => e
    Rails.logger.error "Rakuten API exception: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  def search_by_isbn(isbn)
    return nil if isbn.blank?

    @options[:query][:isbn] = isbn
    response = self.class.get('/', @options)
    
    if response.success?
      books = parse_response(response)
      books.first
    else
      Rails.logger.error "Rakuten API error: #{response.code} - #{response.message}"
      nil
    end
  rescue => e
    Rails.logger.error "Rakuten API exception: #{e.message}"
    nil
  end

  private

  def parse_response(response)
    data = response.parsed_response
    return [] unless data['Items']

    data['Items'].map do |item|
      info = item['Item']
      {
        isbn: info['isbn'],
        title: info['title'],
        author: info['author'],
        publisher: info['publisherName'],
        published_date: parse_date(info['salesDate']),
        image_url: info['largeImageUrl'] || info['mediumImageUrl'] || info['smallImageUrl'],
        rakuten_url: info['itemUrl']
      }
    end
  end

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string) rescue nil
  end
end