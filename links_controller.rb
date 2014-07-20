
    get '/links/?' do
      @links = Link.find_by_sql("SELECT * FROM links")
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
      @selection = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0")
      @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      erb "link_views/links".to_sym
    end

    put '/link/:id' do
      link = Link.find(params[:id])
	if link.update_attributes(params[:link])
	  redirect "/links"
	else
	  redirect to("/")
	end
    end
