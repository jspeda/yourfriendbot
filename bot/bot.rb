class Bot < SlackRubyBot::Bot
  @id = 0

  def self.next_id
    @id = @id % 10 + 1
  end

  command 'say' do |client, data, match|
    Rails.cache.write next_id, { text: match['expression'] }
    client.say(channel: data.channel, text: match['expression'])
  end
end

class GetaRandomQuote < SlackRubyBot::Bot

# random_quote = Quote.order("RANDOM()").first
# def rand_quote
#   rq = Quote.order("RANDOM()").first
# end

  # command 'give me a quote' do |client, data, match|
  #   # client.say(channel: data.channel, text: "#{Quote.order("RANDOM()").first.saying}")
  #   # client.say(channel: data.channel, text: "#{Quote.order("RANDOM()").first.saying} ~ #{Quote.order("RANDOM()").first.author}")
  #   random_quote = Quote.order("RANDOM()").first
  #   client.say(channel: data.channel, text: "_#{random_quote.saying}_ ~ #{random_quote.author}")
  # end
end

# class GetaSpecificQuote < SlackRubyBot::Bot
#   command 'quote #{name}' do |client, data, match|
#     client.say(channel: data.channel, text: "")
#   end
# end

class GetSpecificQuote < SlackRubyBot::Bot
  match /^Give me a quote from (?<author>\w*)$/ do |client, data, match|
    quote = Quote.where(author: match[:author]).order("RANDOM()").first
    client.say(channel: data.channel, text: "_#{quote.saying}_ ~ #{quote.author}")
  end
end

class Weather < SlackRubyBot::Bot
  match /^How is the weather in (?<location>\w*)\?$/ do |client, data, match|
    client.say(channel: data.channel, text: "The weather in #{match[:location]} is nice.")
  end
end
