
    get '/feeds/?' do
      @feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC")
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      erb "feed_views/feeds".to_sym
    end
    
    get '/feed/new' do
	@title = @title + " | New feed"
	@feed = Feed.new
        @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	@sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
	@sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	erb "feed_views/new_feed".to_sym
    end
    
    get '/feed/:id' do
      @feed = Feed.find_by_sql(["SELECT * FROM feeds WHERE feeds.id = ?", params[:id]])
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      if @feed[0].is_deleted == true
        redirect "/feeds"
      end
      @title = @title + " | " + @feed[0].title
      erb "feed_views/show_feed".to_sym
    end
    
    post '/feed/?' do
      @feed = Feed.new(params[:feed])
	if @feed.save #In case of failure to save into the database...
	  redirect "/feed/#{@feed.id}"
	else
	  erb "feed_views/new_feed".to_sym #...the application redirects to the same page.
	end
    end

    put '/feed/:id' do
      feed = Feed.find(params[:id])
	if feed.update_attributes(params[:feed])
	  redirect "/feeds"
	else
	  redirect to("/feed/#{params[:id]}")
	end
    end

