
    get '/feeds/oldal:id/?' do
     if params[:id] == '0'
     redirect '/feeds/oldal1'
     end
    #--------------PAGINATION LOGIC--------------#
    point_a = -10
    point_b = 0
    val = 0
    page = params[:id].to_i
    loop do
      point_a = point_a + 10
      point_b = point_b + 10
      val = val + 1
      break if val >= page
    end
    point_a = point_a.to_s
    point_b = point_b.to_s
    #------------PAGINATION LOGIC END------------#
      @feeds = Feed.find_by_sql("SELECT id, title, created_at FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT " + point_a + ", " + point_b)
    if @feeds[0] == nil
    redirect '/feeds/oldal1'
    end
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      erb "feed_views/feeds".to_sym
    end
    
    get '/feed/new' do
    if env['warden'].authenticate
	@title = @title + " | Új hír bejegyzés"
	@feed = Feed.new
        @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	@sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
	@sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	erb "feed_views/new_feed".to_sym
    else
      redirect '/login'
    end
    end
    
    get '/feed/:id' do
      @feed = Feed.find_by_sql(["SELECT * FROM feeds WHERE feeds.id = ?", params[:id]])
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      if @feed[0].is_deleted == true
        redirect "/feeds"
      end
      @title = @title + " | " + @feed[0].title
      erb "feed_views/show_feed".to_sym
    end
    
    post '/feed/?' do
    if env['warden'].authenticate
      @feed = Feed.new(params[:feed])
	if @feed.save #In case of failure to save into the database...
	  redirect "/feed/#{@feed.id}"
	else
	  redirect "/feed/new" #...the application redirects to the same page.
	end
    else
      redirect '/login'
    end
    end

    put '/feed/:id' do
    if env['warden'].authenticate
      feed = Feed.find(params[:id])
	if feed.update_attributes(params[:feed])
	  redirect "/feeds"
	else
	  redirect to("/feed/#{params[:id]}")
	end
    else
      redirect '/login'
    end
    end

