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

  # context "GET /albums" do
  #   it 'return a list of albums' do
  #     response = get('/albums')

  #     all_albums = "Doolittle, Surfer Rosa, Waterloo, Super Trouper, Bossanova, Lover, Folklore, I Put a Spell on You, Baltimore, Here Comes the Sun, Fodder on My Wings, Ring Ring"

  #     expect(response.status).to eq(200)
  #     expect(response.body).to eq(all_albums)
  #   end
  # end

  context "GET /albums" do
    it 'all the albums as an HTML page' do
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
    it 'returns 200 OK and a list of artists' do
      # Assuming the post with id 1 exists.
      response = get('/artists')

      expected_response = "Pixies, ABBA, Taylor Swift, Nina Simone"

      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
    end
  end

  context "POST /artists" do
    it 'creates a new artists object and returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = post('/artists', name: "Wild nothing", genre: "Indie")

      expect(response.status).to eq(200)
      expect(response.body).to eq("")

      response = get('/artists')
      expect(response.body).to include("Wild nothing")
    end
  end
end
