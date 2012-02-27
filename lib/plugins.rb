# Borrowing chef's knife plugin loading here
# https://github.com/opscode/chef/blob/master/chef/lib/chef/knife/core/subcommand_loader.rb
def load_plugins
  gem_plugins.values.each { |plugin| Kernel.load plugin }
end

def gem_plugins
  # search all gems for central/plugin.rb
  require 'rubygems'
  find_plugins_via_rubygems
end

def find_plugins_via_rubygems
  files = Gem.find_files 'central/plugin.rb'
  # TODO: Not sure how best to handle this yet
  # files.reject! {|f| from_old_gem?(f)}
  plugin_files = {}
  files.each do |file|
    rel_path = file[/(#{Regexp.escape File.join('central', 'plugin')})\.rb/, 1]
    plugin_files[rel_path] = file
  end

  plugin_files
end

class Central
  class Hooks
    include Singleton

    def initialize
      @hooks = {}
    end

    def add action, mod
      @hooks[action] ||= []
      @hooks[action] << mod
    end

    def to_s
      @hooks.to_s
    end

    def [] key
      @hooks[key]
    end
  end
end

# Go ahead and look for plugins
# TODO: This is a bit hacky for now, will need a full on
# plugin class later, so we can track hooks and stuff
# centrally... in central. Yeah, I went there.
load_plugins
