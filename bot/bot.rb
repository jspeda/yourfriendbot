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
   command 'random quote' do |client, data, match|
     random_quote = Quote.order("RANDOM()").first
     client.say(channel: data.channel, text: "_#{random_quote.saying}_ ~ #{random_quote.author}")
   end
end

class GetSpecificQuote < SlackRubyBot::Bot
  match /^quote (?<author>\w*)$/ do |client, data, match|
    quote = Quote.where(author: match[:author]).order("RANDOM()").first
    client.say(channel: data.channel, text: "_#{quote.saying}_ ~ #{quote.author}")
  end
end

# class SpotifyAlbumList < SlackRubyBot::Bot
#   match /^albums (?<artist>\w+)$/ do |client, data, match|
#     artist_link = RSpotify::Artist.search(match[:artist]).first
#     client.say(channel: data.channel, text: "#{artist_link.albums.map do |x|
#       if x.album_type = "album"
#         x.name
#       end
#     end}")
#   end

class SpotifyAlbumList < SlackRubyBot::Bot
  match /^albums (?<artist>\w+)$/ do |client, data, match|
    artist_link = RSpotify::Artist.search(match[:artist]).first
    client.say(channel: data.channel, text: "#{artist_link.albums.map { |x| x.name }.uniq}")
  end
end


  # def list_albums(artist)
  #   albums = artist.albums
  #   albums.map { |x| x.name }
  # end

class SpotifySongSearch < SlackRubyBot::Bot
  match /^song (?<artist>\w+) - (?<title>\w+)$/ do |client, data, match|
    artist_link = RSpotify::Artist.search(match[:artist]).first
    client.say(channel: data.channel, text: "#{artist_link.albums.uniq.map { |x| x.name}}")
  end
end

# class Weather < SlackRubyBot::Bot
#   match /^How is the weather in (?<location>\w*)\?$/ do |client, data, match|
#     client.say(channel: data.channel, text: "The weather in #{match[:location]} is nice.")
#   end
# end
