# Paperclip with AWS S3 demo running on Rails 4.0.0

Tutorial by [Philip Q Nguyen](https://github.com/philipqnguyen)

This is a tutorial and demo to get Paperclip with AWS S3 uploads running on rails 4.0.0.

In this tutorial, we will make a simple site where articles can be created and pictures can be upload as part of the articles.

## Step 1 - Ensure you have all dependencies

Make sure you have an AWS account with an S3 bucket. Keep your access key and your secret access key handy because we will need it in a few steps.

Ensure that you have ImageMagick installed. If you don't, you can install it via Homebrew with `brew install imagemagick`

If you don't already have Rails 4.0.0, you can get it by typing this in your terminal: `gem install rails --version 4.0.0`

Create a new rails app with `rails _4.0.0_ new <appname>`

In your Gemfile, add:
``` ruby
gem 'paperclip', '~> 4.2'
gem 'aws-sdk', '~> 1.55.0'
```
Then run `bundle install`.

## Step 2 - Make the articles

For the purpose of this demo, we will generate an Article scaffold to save some time. `rails g scaffold Article title:string body:text`

bundle exec rake db:migrate

In your config/routes.rb, add `root 'articles#index'`.

## Step 3 - Add Paperclip

Run `rails g paperclip article pic` in order to add a the "pic" column to the Articles table. Then, `bundle exec rake db:migrate`.

Add the following to the model, Article.rb:
``` ruby
  has_attached_file :pic, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :pic, :content_type => /\Aimage\/.*\Z/
```
That will create two additional versions of each pic that is uploaded, a medium and a thumbnail version. In addition, it will also validate that the file is an image. You can make changes to the sizes or add additional variations if you want.

Add `<%= image_tag @article.pic.url(:medium) %>` to the article's show page.

Add `<%= f.file_field :pic %>` in your form and add `:html => { :multipart => true }` to the top of your form so that it looks like this:

``` erb
<%= form_for(@article, :html => { :multipart => true }) do |f| %>
  <% if @article.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>

      <ul>
      <% @article.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <%= f.file_field :pic %>

  <div class="field">
    <%= f.label :title %><br>
    <%= f.text_field :title %>
  </div>
  <div class="field">
    <%= f.label :body %><br>
    <%= f.text_area :body %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```
## Step 4 - Configure Paperclip and try it!

Add this to your config/environments/development.rb. Also add it to your production.rb if you plan to use this in production.
``` ruby
  Paperclip.options[:command_path] = "/usr/local/bin/"

  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
```
Now you need to add the S3 bucket name, S3 access key and S3 secret access key into your shell profile. If you are on a Mac and using bash, put this into your .bash_profile:

``` ruby
export S3_BUCKET_NAME="<name of your bucket>"
export AWS_ACCESS_KEY_ID="<your key>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"
```

Launch the server and try it out. If you get an error upon uploading a picture that says: “The bucket you are attempting to access must be addressed using the specified endpoint. Please send all future requests to this endpoint.” You will need to add this `:s3_host_name => 's3-us-west-2.amazonaws.com'` into your development.rb and likewise in your production.rb so that it looks like this:

``` ruby
  Paperclip.options[:command_path] = "/usr/local/bin/"

  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :s3_host_name => 's3-us-west-2.amazonaws.com', # this
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
```

Now it should work. I hope this helps!

## References used in this tutorial

- [Heroku](https://devcenter.heroku.com/articles/paperclip-s3)
- [Paperclip](https://github.com/thoughtbot/paperclip)

## License

MIT
