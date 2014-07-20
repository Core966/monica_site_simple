    
    get '/blog/?' do
      @posts = Post.find_by_sql("SELECT * FROM posts WHERE is_deleted = 0 ORDER BY id DESC")
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      erb "post_views/posts".to_sym
    end
    
    get '/blog/new' do
	@title = @title + " | New Post"
	@post = Post.new
        @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	@sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
	@sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
	erb "post_views/new_post".to_sym
    end
    
    get '/blog/:id' do
      @post = Post.find_by_sql("SELECT posts.* FROM posts WHERE posts.id = " + params[:id])
      @sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      @sidebar_links = Link.find_by_sql("SELECT * FROM links WHERE href <> ''")
      @sidebar_feeds = Feed.find_by_sql("SELECT * FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3")
      if @post[0].is_deleted == true
        redirect "/blog"
      end
      @title = @title + " | " + @post[0].title
      erb "post_views/show_post".to_sym
    end
    
    post '/blog/?' do
      @post = Post.new(params[:post])
	if @post.save #In case of failure to save into the database...
	  redirect "/blog/#{@post.id}"
	else
	  erb "post_views/new_post".to_sym #...the application redirects to the same page.
	end
    end

    put '/blog/:id' do
      post = Post.find(params[:id])
	if post.update_attributes(params[:post])
	  redirect "/blog"
	else
	  redirect to("/blog/#{params[:id]}")
	end
    end

