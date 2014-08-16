
    get '/links/?' do
    if env['warden'].authenticate
      @links = Link.find_by_sql("SELECT * FROM links")
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
      @selection = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0")
      @sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      erb "link_views/links".to_sym
    else
      redirect '/login'
    end
    end

    put '/link/:id' do
    if env['warden'].authenticate
      link = Link.find(params[:id])
	if link.update_attributes(params[:link])
	  redirect "/links"
	else
	  redirect to("/")
	end
    else
      redirect '/login'
    end
    end
