#!/bin/bash --login

# Get the app name
echo "Enter your Rails app name:"
read app_name

# Create new Rails app with PostgreSQL, Tailwind CSS
rails new $app_name --css tailwind --database=postgresql

# Move into the app directory
cd $app_name

# Create a gemset with the name
rvm gemset create $app_name && rvm gemset use $app_name

# Install gems
bundle install

# Set up database
bundle exec rails db:drop
bundle exec rails db:setup

# Create migration to enable 'pgcrypto' extension
bundle exec rails g migration enable_pgcrypto_extension

# Edit the migration file to enable 'pgcrypto' extension
echo 'class EnablePgcryptoExtension < ActiveRecord::Migration[7.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end
end' > db/migrate/$(ls db/migrate | grep enable_pgcrypto_extension | tail -n 1)

# Run migrations to enable 'pgcrypto' extension
bundle exec rails db:migrate

# Create config/initializers/generators.rb file and configure UUID as primary key
mkdir -p config/initializers
echo 'Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end' > config/initializers/generators.rb

# Add gems to Gemfile
echo 'gem "devise"' >> Gemfile
echo 'gem "friendly_id"' >> Gemfile
echo 'gem "paper_trail"' >> Gemfile
echo 'gem "dotenv-rails"' >> Gemfile
echo 'gem "rubocop"' >> Gemfile
echo 'gem "hotwire-livereload", group: [:development]' >> Gemfile
echo 'gem "annotate", group: [:development]' >> Gemfile
echo 'gem "byebug", group: [:development, :test]' >> Gemfile

# Install the gems
bundle install

# Install importmap
rails importmap:install

# Install tailwind css
bundle exec rails tailwindcss:install

# Install Devise
bundle exec rails generate devise:install

# Install Friendly ID gem
bundle exec rails generate friendly_id

# Install Annotate gem
bundle exec rails g annotate:install

# Install PaperTrail gem
bundle exec rails generate paper_trail:install [--with-changes] [--uuid]

# Install Active Storage
bundle exec rails active_storage:install

# Install Livereload
bundle exec rails livereload:install

# Run migrations
bundle exec rails db:migrate

# Create the sluggable concern file
mkdir -p app/models/concerns
echo '# frozen_string_literal: true

# Allow models to have slugs
module Sluggable
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
  end

  class_methods do
    def friendly_slug_scope(to_slug:, use: :slugged)
      friendly_id to_slug, use: use
    end
  end
end' > app/models/concerns/sluggable.rb


# Initialize Git and commit changes
git init
git add .
git commit -m "Initialize project"

# Create bash alias to set up RVM Ruby version and gemset
ruby_version=`ruby -v | awk '{print $2}'`
echo "alias $app_name=\"rvm use $ruby_version && rvm gemset use $app_name\"" >> ~/.bashrc
source ~/.bashrc

# Display success message
echo "Your Rails app $app_name is set up with PostgreSQL, Tailwind CSS, Devise, Friendly ID, Annotate, PaperTrail, and Active Storage."

# Start rails app
`$app_name`
./bin/dev
