require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  fixtures :all
  render_views
	describe "as an admin" do
		
		before(:each) do
		  @admin = Factory(:user)
			@admin.roles = ['admin'] 
			sign_in @admin
		end
		
	  it "index action should render index template" do
	    get :index
	    response.should render_template(:index)
	  end

	  it "show action should render show template" do
	    get :show, :id => Post.first
	    response.should render_template(:show)
	  end

	  it "new action should render new template" do
	    get :new
	    response.should render_template(:new)
	  end

	  it "create action should render new template when model is invalid" do
	    Post.any_instance.stubs(:valid?).returns(false)
	    post :create
	    response.should render_template(:new)
	  end

	  it "create action should redirect when model is valid" do
	    Post.any_instance.stubs(:valid?).returns(true)
			Post.any_instance.stubs(:to_param).returns("1")
	    post :create
	    response.should redirect_to(post_url(1))
	  end

	  it "edit action should render edit template" do
	    get :edit, :id => Post.first
	    response.should render_template(:edit)
	  end

	  it "update action should render edit template when model is invalid" do
	    Post.any_instance.stubs(:valid?).returns(false)
	    put :update, :id => Post.first
	    response.should render_template(:edit)
	  end

	  it "update action should redirect when model is valid" do
	    Post.any_instance.stubs(:valid?).returns(true)
	    put :update, :id => Post.first
	    response.should redirect_to(post_url(assigns[:post]))
	  end

	  it "destroy action should destroy model and redirect to index action" do
	    post = Post.first
	    delete :destroy, :id => post
	    response.should redirect_to(posts_url)
	    Post.exists?(post.id).should be_false
	  end	  
	end

	describe "as a registered user" do
		
		before(:each) do
		  @user = Factory(:user)
			sign_in @user
		end
		
	  it "index action should render index template" do
	    get :index
	    response.should render_template(:index)
	  end

	  it "show action should render show template" do
			Post.first.published = true
	    get :show, :id => Post.first.id
	    response.should render_template(:show)
	  end

	  it "new action should deny access" do
	    get :new
	    response.should redirect_to root_path
			flash[:error].should =~ /access denied/i
	  end

	  it "create action should deny access and not store the post" do
	    Post.any_instance.stubs(:valid?).returns(true)
			lambda do
	    	post :create
				response.should redirect_to root_path
			end.should change(Post, :count).by(0)
			flash[:error].should =~ /access denied/i
	  end

	  it "edit action should deny access" do
	    get :edit, :id => Post.first
	    response.should redirect_to root_path
			flash[:error].should =~ /access denied/i
	  end

	  it "update action should deny access" do
	    Post.any_instance.stubs(:valid?).returns(true)
	    put :update, :id => Post.first
			response.should redirect_to root_path
			flash[:error].should =~ /access denied/i
	  end

	  it "destroy action should destroy model and redirect to index action" do
	    post = Post.first
	    delete :destroy, :id => post
	    response.should redirect_to root_path
			flash[:error].should =~ /access denied/i
	    Post.exists?(post.id).should be_true
	  end	  
	end

	describe "as an author" do
		
		before(:each) do
		  @author = Factory(:user)
			@author.roles = ['author'] 
			sign_in @author
		end
		
	  it "index action should render index template" do
	    get :index
	    response.should render_template(:index)
	  end

	  it "show action should render show template" do
	    get :show, :id => Post.first
	    response.should render_template(:show)
	  end

	  it "new action should render new template" do
	    get :new
	    response.should render_template(:new)
	  end

	  it "create action should render new template when model is invalid" do
	    Post.any_instance.stubs(:valid?).returns(false)
	    post :create
	    response.should render_template(:new)
	  end

	  it "create action should redirect when model is valid" do
	    Post.any_instance.stubs(:valid?).returns(true)
			Post.any_instance.stubs(:title).returns("test")
			Post.any_instance.stubs(:id).returns(1)
	    post :create
	    response.should redirect_to(post_url(assigns[:post]))
	  end

	  it "edit action should render edit template for an owned post" do
			@author.posts = [Post.first]
	    get :edit, :id => Post.first
	    response.should render_template(:edit)
	  end

	  it "edit action should deny access for non owned posts" do
			@author.posts = [Post.first]
			@author2 = Factory(:user, :name => "other author", :email => Factory.next(:email))
			@author2.posts = [Post.last]
	    get :edit, :id => Post.last
	    response.should redirect_to root_path
			flash[:error].should =~ /access denied/i
	  end

	  it "update action should render edit template when model is invalid" do
			@author.posts = [Post.first]
	    Post.any_instance.stubs(:valid?).returns(false)
	    put :update, :id => Post.first
	    response.should render_template(:edit)
	  end

	  it "update action should redirect when model is valid" do
			@author.posts = [Post.first]
	    Post.any_instance.stubs(:valid?).returns(true)
	    put :update, :id => Post.first
	    response.should redirect_to(post_url(assigns[:post]))
	  end

	  it "destroy action should destroy model and redirect to index action" do
			@author.posts = [Post.first]
	    post = Post.first
	    delete :destroy, :id => post
	    response.should redirect_to(posts_url)
	    Post.exists?(post.id).should be_false
	  end	  
	end
 

end
