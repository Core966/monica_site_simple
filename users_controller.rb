
    get '/users/?' do
      if env['warden'].authenticate
        @title = @title + " | Admin Panel"
        @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	@sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
	@sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
        @users = User.find_by_sql("SELECT id, username, CONCAT('...', SUBSTRING(email,7, 4), '...') AS partial_email FROM users WHERE is_deleted = 0")
        erb "user_views/admin".to_sym
      else
	redirect '/login'
      end
    end

    get '/users/new' do
      if env['warden'].authenticate
	@title = @title + " | Új felhasználó"
        @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	@sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
	@sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	@user = User.new
	erb "user_views/new_user".to_sym
      else
	redirect '/login'
      end
    end
    
    post '/users/?' do
      if env['warden'].authenticate
      @user = User.new(params[:user])
	if @user.save #In case of failure to save into the database...
	  redirect "/login"
	else
	  redirect "/users/new".to_sym #...the application redirects to the same page.
	end
      else
	redirect '/login'
      end
    end
    
    put '/users/:id' do
      if env['warden'].authenticate
        user = User.find(params[:id])
	  if user.update_attributes(params[:user])
	    redirect "/users"
	  else
	    redirect "/"
	  end
      else
	redirect '/login'
      end
    end
