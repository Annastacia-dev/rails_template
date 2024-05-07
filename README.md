## rails_template.sh
bash script for initializing a new rails app.

## what
- postgresql database
- tailwind css for styling
- install devise gem for auth
- install annotate in development group to annotate models
- install byebug gem in development and test group for debugging
- install papertrail gem for tracking changes in your models
- install friendly id gem to generate slugs for models
- install active storage
- enable 'pgcryypto' extension and configure `initializers/generators.rb` to use `uuid` as the `primary_key` for active record
- create a model concern `app/models/concerns/sluggable.rb` with a class method that can be called to clug your models.
- create a gemset with the same name as your app.
- create a bash alias to use the ruby version & gemset.
- initialize git & commit changes
- start the rails app

  ## how
  - while in the path containing the file run `chmod +x rails_template.sh` to make it executable
  - then run `./rails_template.sh` or whichever path you want your rails app to be contained
  - you will be prompted to enter the app name then the script will run.
