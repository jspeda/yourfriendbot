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

class SpotifySearch < SlackRubyBot::Bot
  # finds an artist's albums
  match /^albums (?<artist>.+)$/ do |client, data, match|
    artist_link = RSpotify::Artist.search(match[:artist]).first
    client.say(channel: data.channel, text: "#{artist_link.albums.map { |x| x.name }.uniq}")
  end
  # finds an artist's top tracks
  match /^top_tracks (?<artist>.+)$/ do |client, data, match|
    artist_link = RSpotify::Artist.search(match[:artist]).first
    client.say(channel: data.channel, text: "#{artist_link.top_tracks(:US).map { |x| x.name }.uniq}")
  end
  # links a random song from specified artist's top tracks
  match /^random_song (?<artist>.+)$/ do |client, data, match|
    artist_link = RSpotify::Artist.search(match[:artist]).first
    client.say(channel: data.channel, text: "#{artist_link.top_tracks(:US).sample.external_urls}")
  end

  # links to first result of song search
  match /^play (?<title>.+)$/ do |client, data, match|
    song_link = RSpotify::Track.search(match[:title]).first
    client.say(channel: data.channel, text: "#{song_link.external_urls}")
  end

  help do
    title 'Your Friend'
    desc 'This bot is your friend and will always be there for you'

    command 'random quote' do
      desc 'Gives you a random quote from the esteemed members of this community'
    end

    command 'quote <Lastname>' do
      desc "Gives you a quote from a specific person. Correct usage(excluding brackets): [quote Obama]\n" \
      'Incorrect usage: [quote Barack]'
    end

    command 'albums <artist>' do
      desc 'lists the albums (and singles) for the specified artist via Spotify'
    end

    command 'top_tracks <artist>' do
      desc 'lists the top tracks for the specified artist via Spotify'
    end

    command 'random_song <artist>' do
      desc 'links a random song from the specified artist\'s top tracks via Spotify'
    end

    command 'play <song title>' do
      desc 'links the first result of the song title searched via Spotify'
    end


  end

end


# class SpotifySongSearch < SlackRubyBot::Bot
#   match /^song (?<artist>.*) - (?<title>.*)$/ do |client, data, match|
#     artist_link = RSpotify::Artist.search(match[:artist]).first
#     client.say(channel: data.channel, text: "#{artist_link.albums.uniq.map { |x| x.name}}")
#   end
# end
