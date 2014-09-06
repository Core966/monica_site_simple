
    get '/blog/oldal:id/?' do
     if params[:id] == '0'
     redirect '/blog/oldal1'
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
      @posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT " + point_a + ", " + point_b)
    if @posts[0] == nil
    redirect '/blog/oldal1'
    end
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      erb "post_views/posts".to_sym
    end
    
    get '/blog/new' do
    if env['warden'].authenticate
	@title = @title + " | Új blog bejegyzés"
	@post = Post.new
        @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	@sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
	@sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	erb "post_views/new_post".to_sym
    else
      redirect '/login'
    end
    end
    
    get '/blog/:id' do
      @post = Post.find_by_sql(["SELECT * FROM posts WHERE posts.id = ?", params[:id]])
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      if @post[0].is_deleted == true
        redirect "/blog"
      end
      @title = @title + " | " + @post[0].title
      erb "post_views/show_post".to_sym
    end
    
    post '/blog/?' do
    if env['warden'].authenticate
      @post = Post.new(params[:post])
	if @post.save #In case of failure to save into the database...
	  redirect "/blog/#{@post.id}"
	else
	  redirect "/blog/new" #...the application redirects to the same page.
	end
    else
      redirect '/login'
    end
    end

    put '/blog/:id' do
    if env['warden'].authenticate
      post = Post.find(params[:id])
	if post.update_attributes(params[:post])
	  redirect "/blog"
	else
	  redirect to("/blog/#{params[:id]}")
	end
    else
      redirect '/login'
    end
    end

