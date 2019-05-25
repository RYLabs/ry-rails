require "fileutils"
require "shellwords"
require "tmpdir"

RUBY_VERSION = "2.6.2"
RAILS_REQUIREMENT = ">= 5.2.3"
TEMPLATE_REPO = "https://github.com/RYLabs/ry-rails"

def apply_template!
  assert_minimum_rails_version
  assert_yarn_installed
  add_template_repository_to_source_path

  template 'Gemfile.tt', force: true
  template 'README.md.tt', force: true

  apply 'config/template.rb'
  apply 'app/template.rb'

  ask_optional_options

  install_optional_gems

  after_bundle do
    setup_gems

    run 'bundle binstubs bundler --force'

    setup_docker
    setup_seeds

    rails_command 'db:create db:migrate'
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def assert_yarn_installed
  if !system "bash --login -c 'yarn -v'"
    prompt = "This template requires Yarn. Continue anyway?"
    exit 1 if no?(prompt)
  end
end

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git :clone => [
      "--quiet",
      TEMPLATE_REPO,
      tempdir
    ].map(&:shellescape).join(" ")
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.gsub("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def ask_optional_options
  @graphql = yes?('Do you want to add GraphQL to your app?')
end

def install_optional_gems
  add_graphql if @graphql
end

def add_graphql
  insert_into_file 'Gemfile', <<GEMFILE, after: /'cancancan'\n/

  # GraphQL
gem 'graphql'
gem 'graphiql-rails', group: :development
gem 'devise-token_authenticatable'
GEMFILE
end

def setup_gems
  generate "rspec:install"

  setup_devise
  setup_cancancan
  setup_graphql if @graphql
end

def setup_devise
  generate "model", "User", "first_name:string", "last_name:string"
  generate "devise:install"
  generate "devise", "User"
  generate "devise:views"
end

def setup_cancancan
  generate "cancan:ability"
end

def setup_graphql
  generate "graphql:install"

  copy_file 'app/graphql/types/user_type.rb'
  copy_file 'app/graphql/types/auth_type.rb'
  copy_file 'app/graphql/types/query_type.rb', force: true
  copy_file 'app/graphql/types/mutation_type.rb', force: true

  copy_file 'app/graphql/mutations/base_mutation.rb'
  copy_file 'app/graphql/mutations/sign_in.rb'

  copy_file 'app/controllers/concerns/api_context.rb'

  copy_file 'config/initializers/token_authenticatable.rb'

  generate 'migration', 'add_authentication_token_to_users'
  migration_file = Dir.glob('db/migrate/*_add_authentication_token_to_users.rb').first
  insert_into_file(migration_file, <<MIGRATION, after: /def change\n/)
    add_column :users, :authentication_token, :text
    add_column :users, :authentication_token_created_at, :datetime
    add_index :users, :authentication_token, unique: true
MIGRATION

  # app_schema.rb
  insert_into_file "app/graphql/#{app_name.underscore}_schema.rb",
    "  context_class(#{app_name.underscore.classify}Context)\n",
    after: /query\(Types::QueryType\)\n/

  # app_context.rb
  template "app/graphql/context.rb.tt", "app/graphql/#{app_name.underscore}_context.rb"

  # graphql_controller.rb
  insert_into_file 'app/controllers/graphql_controller.rb', "  include APIContext\n", after: /< ApplicationController\n/
  gsub_file 'app/controllers/graphql_controller.rb', /context = \{.*?\}/m, 'context = build_api_context'

  # user.rb
  insert_into_file 'app/models/user.rb',
    ",\n         :token_authenticatable\n",
    after: /, :validatable/
end

def setup_docker
  template 'Dockerfile.tt'
  template 'docker-compose.yml.tt'
  template 'entrypoint.sh.tt'
end

def setup_seeds
  copy_file 'db/seeds.rb', force: true
  copy_file 'db/seeds/01_create_users.rb'
end

# launch the main template creation method
apply_template!
