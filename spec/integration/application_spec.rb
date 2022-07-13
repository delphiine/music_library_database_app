require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  before(:each) do 
    reset_artists_table
    reset_albums_table
  end 

  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "GET /albums" do
    it 'all albums on a HTML page with links to album info' do
      response = get('/albums')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Albums</h1>')
      expect(response.body).to include('Title: Doolittle')
      expect(response.body).to include('<a href="/albums/2">')
      expect(response.body).to include('<a href="/albums/3">')
      expect(response.body).to include('<a href="/albums/4">')
    end
  end

  context 'GET /albums/:id' do
    it 'returns information about album 1' do
      # Assuming the post with id 1 exists.
      response = get('/albums/1')

      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Doolittle</h1>")
      expect(response.body).to include("<p>Release year: 1989</p>")
      expect(response.body).to include("<p>Artist: Pixies")
    end

    it 'returns information about album 2' do
      # Assuming the post with id 2 exists.
      response = get('/albums/2')

      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Surfer Rosa</h1>")
      expect(response.body).to include("<p>Release year: 1988</p>")
      expect(response.body).to include("<p>Artist: Pixies</p>")
    end
  end 

  context "GET /albums/new" do
    it "implements a form page to add a new album" do
      response = get("/albums/new")

      expect(response.status).to eq(200)
      expect(response.body).to include('<form method="POST" action="/albums">')
      expect(response.body).to include('<input type="text" name="album_title" />')
      expect(response.body).to include('<input type="text" name="album_release_year" />')
      expect(response.body).to include('<input type="text" name="album_artist_id" />')
    end
  end

  context "POST /albums" do
    it "creates a new album" do
      response = post("albums", title: "Voyage", release_year: 2022, artist_id: 2)

      expect(response.status).to eq(200)
      expect(response.body).to eq('')

      response = get('/albums')
      expect(response.body).to include("Voyage")
    end
  end


  context "GET /artists" do
    it "returns an HTML page with the list of artists, and links for each artist listed" do
      response = get('/artists') 

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Artists</h1>')
      expect(response.body).to include('Pixies</a>')
      expect(response.body).to include('<a href="/artists/ 2">')
      expect(response.body).to include('<a href="/artists/ 3">')
      expect(response.body).to include('<a href="/artists/ 4">')
    end
  end

  context "GET /artists/:id" do
    it "returns an HTML page showing details for a single artist" do
      response = get('/artists/1')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Pixies</h1>')
      expect(response.body).to include('<p>Genre: Rock</p>')
    end
  end

  context "GET /artists/new" do
    it "implements a form page to add a new artist" do
      response = get("/artists/new")

      expect(response.status).to eq(200)
      expect(response.body).to include('<form method="POST" action="/artists">')
      expect(response.body).to include('<input type="text" name="artist_name" />')
      expect(response.body).to include('<input type="text" name="artist_genre" />')
    end
  end

  context "POST /artists" do
    it 'creates a new artists object and returns 200 OK' do
      response = post('/artists', name: "Wild nothing", genre: "Indie")

      expect(response.status).to eq(200)
      expect(response.body).to eq("")

      response = get('/artists')
      expect(response.body).to include("Wild nothing")
    end
  end
end
