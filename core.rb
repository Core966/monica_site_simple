require 'bundler/setup'
require 'sinatra'
require 'active_record'
require 'yaml'
require 'warden'
require 'bcrypt'
require 'rack/csrf'

#Load all models in the model directory:

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/models")
Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require File.basename(model, '.*') }

# The database configuration data ready from the below yaml file.

# Necessary format:

# db_name: <db name here>
# db_host: <hostname here>
# db_username: <db username here>
# db_password: <db user password here>

APP_CONFIG = YAML.load_file('./config/database.yml')

ActiveRecord::Base.establish_connection(
encoding: APP_CONFIG['db_encoding'],
adapter: APP_CONFIG['db_adapter'],
host: APP_CONFIG['db_host'],
database: APP_CONFIG['db_name'],
username: APP_CONFIG['db_username'],
password: APP_CONFIG['db_password']
)

####################################################

	configure do
	  set :views, "#{File.dirname(__FILE__)}/views"
	  enable :sessions
	  use Rack::Session::Cookie, :expire_after => 60*60*3, secret: "nothingissecretontheinternet"
	  use Rack::Csrf
	  use Rack::MethodOverride
	end
	
	require File.join(File.dirname(__FILE__), './warden_auth.rb')

	before do
	  @title = 'Tóth Mónika weboldala'
	  @author = 'Tóth Mónika'
	end

	# root page
	get '/' do
	  @posts = Post.find_by_sql("SELECT id, title, CONCAT(SUBSTRING(body,1, 250), '...') AS partial_body FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 5") #We are only displaying the first 250 characters of a given post.
	  @sidebar_posts = Post.find_by_sql("SELECT * FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
	  @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  erb :home
	end

	get '/about/?' do
	  @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
	  @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  erb :about
	end
	
	get '/login/?' do
	  @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
	  @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  erb :login
	end
	
	post '/login' do
    	  if env['warden'].authenticate
	    redirect '/blog'
	  else
	    redirect '/'
	  end
	end
	
	get '/logout' do
          env['warden'].logout
	  session.clear
          redirect '/'
	end

	get '/misc' do
          @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
          @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
	  @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  erb :misc
	end
	
	post '/search' do
	  @posts = Post.find_by_sql(["SELECT id, title, body FROM posts WHERE (title LIKE ? OR body LIKE ?) AND is_deleted = 0", "%" + params[:search][:keyword] + "%", "%" + params[:search][:keyword] + "%"])
          @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
          @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
	  @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	  erb :search
	end

#Enable the below in order to activate the CRUD operations of posts and their comments:
require File.join(File.dirname(__FILE__), './posts_controller.rb')
#Or you may delete the post_views folder and all its files within. You must also edit the menu.erb partial.

require File.join(File.dirname(__FILE__), './users_controller.rb')

require File.join(File.dirname(__FILE__), './feeds_controller.rb')

require File.join(File.dirname(__FILE__), './links_controller.rb')
