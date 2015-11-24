require "sinatra"
require "pg"
require 'pry'
require_relative "./app/models/article"

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/articles/' do
  db_connection do |conn|
    article_list = conn.exec('SELECT * FROM articles;')
    erb :index, locals: {article_list: article_list}
  end
end

get '/new' do
  erb :new, locals: { title: params[:title], url: params[:url], description: params[:description] }
end

post '/new' do
  title = params["title"]
  url = params["url"]
  description = params["description"]

  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (title, url, description) VALUES ($1, $2, $3)", [title, url, description])
  end

  redirect '/articles/'
end

set :views, File.join(File.dirname(__FILE__), "app/views")
