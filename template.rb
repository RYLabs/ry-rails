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

  after_bundle do
    generate 'rspec:install'
    generate "devise:install"
    generate "devise", "User"
    generate "devise:views"
    generate "cancan:ability"

    run 'bundle binstubs bundler --force'

    setup_docker
    setup_seeds

    rails_command "db:create db:migrate"
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

def setup_docker
  template 'Dockerfile.tt'
  copy_file 'docker-compose.rails.yml', 'docker-compose.yml'
  copy_file 'entrypoint.sh'
end

def setup_seeds
  copy_file 'db/seeds.rb'
  copy_file 'db/seeds/01_create_users.rb'
end

# launch the main template creation method
apply_template!