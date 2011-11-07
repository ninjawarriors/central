require 'rubygems'
require 'sinatra'
require 'redis'

# To use, simply start your Redis server and boot this
# example app with:
#   ruby example_note_keeping_app.rb
#
# Point your browser to http://localhost:4567 and enjoy!
#

# Create the Redis client when the script starts
$redis = Redis.new

helpers do
  def tag_link(t, title = nil)
    arr = t.is_a?(Array) ? t : (@current_tags || []).dup.push(t)
    path = arr.uniq.join('/')
    %!<a href="/tags/#{path}">#{title || t}</a>!
  end
end

# Loads all notes given by an array of IDs in a single Redis call
def load_notes(ids)
  if ids.empty?
    []
  else
    $redis.mget(*ids.map { |id| "note-#{id}" }).map { |raw| Marshal.load(raw) }
  end
end

get '/' do
  @notes = load_notes $redis.smembers("all-notes")
  erb :index
end

get '/tags/*' do
  @current_tags = params[:splat].first.split('/')
  redirect '/' if @current_tags.empty?

  # Names of the tag-sets
  sets = @current_tags.map { |t| "tag-#{t}" }

  # Load all notes that reside in the intersection of these sets
  @notes = load_notes $redis.sinter(*sets)

  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  # Extract tags from request parameters
  tags = params[:tags].gsub(/\s+/, '').split(',')

  # Get ID for the new note
  note_id = $redis.incr(:note_counter)

  # Store the note
  $redis.set("note-#{note_id}", Marshal.dump({ :contents => params[:contents], :tags => tags }))
  $redis.sadd("all-notes", note_id)

  # Add the ID to the tag-sets
  tags.each { |t| $redis.sadd("tag-#{t}", note_id) }

  redirect '/'
end

__END__
@@ layout
<html>
  <head>
    <title>My notes</title>
    <style type="text/css" media="screen">
      #main {
        font-family: Helvetica;
        width: 400px;
        margin: 60px auto;
      }
      #head div {
        float: right;
        text-align: right;
        font-size: 0.8em;
      }
      a {
        text-decoration: none;
        color: #000;
      }
      label {
        font-size: 0.8em;
        display: block;
        width: 70px;
      }
      legend {
        font-weight: bold;
      }
      input, textarea {
        width: 100%;
        margin-bottom: 1em;
      }
      input.submit {
        width: auto;
        float: right;
        font-weight: bold;
      }
      div.note {
        border-top: 2px dashed #bbb;
        padding: 0.3em 1em;
        background-color: #FFFFA0;
        margin-bottom: 1em;
      }
      div.note .tags {
        font-size: 0.6em;
        font-style: italic;
        color: #333;
      }
      div.note .tags > a {
        color: #333;
      }
      h3.tags a span {
        color: #f00;
        font-size: 0.8em;
      }
    </style>
  </head>
  <div id="main">
    <div id="head">
      <div>
        <a href="/new">new note</a>
      </div>
      <h1>My notes</h1>
    </div>
    <div>
      <%= yield %>
    </div>
  </div>
</html>

@@ new
<fieldset>
  <legend>New note</legend>
  <form action="/new" method="post">
    <label>Contents:</label>
    <textarea name="contents"></textarea>
    <label>Tags:</label>
    <input type="text" name="tags" />
    <input type="submit" value="Save" class="submit" />
  </form>
</fieldset>

@@ index
<% unless @current_tags.nil? %>
  <h3 class="tags">
    Notes tagged with:
    <%= @current_tags.map do |t|
      t + tag_link(@current_tags - [t], "<span>(x)</span>")
    end.join(', ') %>
  </h3>
<% end %>

<% @notes.each do |note| %>
  <div class="note">
    <div class="tags">
      Tags: <%= note[:tags].map { |tag| tag_link(tag) }.join(', ') %>
    </div>
    <pre><%= note[:contents] %></pre>
  </div>
<% end %>
