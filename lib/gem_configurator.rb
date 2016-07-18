require_relative './file_creator.rb'

def add_gem_configs
  bundle
  rspec_config
  read_configs
  factory_girl_config
  database_cleaner_config
  shoulda_matchers_config
  code_climate_config
  rubocop_config
  tape_config
end

def bundle
  run 'bundle'
end

def clean_up_auto_files
  gsub_file 'config/environments/development.rb',
            /config.action_mailer.perform_caching/,
            '# config.action_mailer.perform_caching'
  gsub_file 'config/environments/development.rb',
            /config.file_watcher/,
            '# config.file_watcher'
  gsub_file 'config/environments/test.rb',
            /config.action_mailer.perform_caching/,
            '# config.action_mailer.perform_caching'
  gsub_file 'config/environments/test.rb',
            /config.public_file_server.enabled/,
            '# config.public_file_server.enabled'
  gsub_file 'config/environments/test.rb', /config.public_file_server.headers/, ''
  gsub_file 'config/environments/test.rb', /'Cache-Control'/, ""
  gsub_file 'config/environments/test.rb', /}/, ""
  gsub_file 'config/initializers/new_framework_defaults.rb',
            /ActiveSupport.to_time_preserves_timezone/,
            '# ActiveSupport.to_time_preserves_timezone'
  gsub_file 'config/initializers/new_framework_defaults.rb',
            /ActiveSupport.halt_callback_chains_on_return_false/,
            '# ActiveSupport.halt_callback_chains_on_return_false'
end

def rspec_config
  clean_up_auto_files
  generate 'rspec:install'
end

def read_configs
  gsub_file 'spec/rails_helper.rb', /# Dir/, "Dir"
end

def factory_girl_config
  file 'spec/support/factory_girl.rb', render_file(path("factory_girl.rb"))
end

def database_cleaner_config
  file 'spec/support/database_cleaner.rb', render_file(path("database_cleaner.rb"))
end

def shoulda_matchers_config
  file 'spec/support/shoulda_matchers.rb', render_file(path("shoulda_matchers.rb"))
end

def code_climate_config
  inside 'spec' do
    inject_into_file 'spec_helper.rb', after: "# users commonly want.\n" do
      <<-RUBY
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
      RUBY
    end
  end
end

def rubocop_config
  inside 'spec' do
    inject_into_file 'spec_helper.rb', after: "RSpec.configure do |config|\n" do
      <<-RUBY
  config.after(:suite) do
    examples = RSpec.world.filtered_examples.values.flatten
    if examples.none?(&:exception)
      system("echo '\n' && bundle exec rubocop")
      exit $? if $? != 0
    end
  end
      RUBY
    end
  end
end

def tape_config
  run 'tape installer install'
end

def smashing_docs?
  if yes?("Add smashing_docs for API documentation? (y/n)")
    @smashing_docs = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<-RUBY
  # Use smashing_docs for API documentation
  gem 'smashing_docs'
      RUBY
    end
  end
end

def devise_auth?
  if yes?("Add devise_token_auth? (y/n)")
    @devise_auth = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do
      <<-RUBY
gem 'devise_token_auth'
      RUBY
    end
  end
end

def devise?
  if yes?("Add devise? (y/n)")
    @devise = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do
      <<-RUBY
gem 'devise'
      RUBY
    end
  end
end

def cucumber_capybara?
  if yes?("Add cucumber-rails and capybara? (y/n)")
    @cucumber_capybara = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<-RUBY
  # Use cucumber-rails for automated feature tests
  gem 'cucumber-rails', require: false
  # Use capybara to simulate how a user interacts with the app
  gem 'capybara'
      RUBY
    end
  end
end

def install_optional_gems
  bundle if @smashing_docs || @devise || @devise_auth || @cucumber_capybara
  generate 'docs:install' if @smashing_docs
  generate 'devise:install' if @devise
  generate 'cucumber:install' if @cucumber_capybara
end
