# Handle loading individual seed files from db/seeds and provide a way for
# individual files to share attributes. Set SEED env to run only one seed file.
#
#    rake db:seed SEED=01_create_users
#

class Seed
  attr_reader :attributes

  def initialize
    @attributes = {}.with_indifferent_access
  end

  def set_attribute(key, val)
    attributes[key] = val
  end

  def load_files(dir)
    files = Dir.glob(File.join(dir, '*.rb'))
    files.sort.each { |fn| load_file(fn) }
  end

  def load_file(fn)
    puts "*** Loading seed file #{File.basename(fn)}..."
    ActiveRecord::Base.transaction do
      instance_eval(File.read(fn), fn.to_s)
    end
  end

  def method_missing(name, *args, &block)
    if attributes.has_key?(name) && args.length == 0
      attributes[name]
    else
      super
    end
  end
end

seed = Seed.new
if (seed_name = ENV['SEED']).present?
  seed_file = Rails.root.join('db', 'seeds', "#{ENV['SEED']}.rb")
  if File.exists? seed_file
    seed.load_file(seed_file)
  else
    puts "seed not found: #{seed_name}"
  end
else
  seed.load_files(Rails.root.join('db', 'seeds'))
end