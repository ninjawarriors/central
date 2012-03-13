class Central

  class Hooks
    include Singleton

    attr_reader :hooks, :disabled_hooks
    def initialize
      @hooks = {}
      @disabled_hooks = {}
    end

    def register hook, mod
      Central.debug "Adding hook: #{mod}##{hook} (#{mod.object_id})"
      @hooks[hook] ||= []
      @hooks[hook] << mod unless @hooks[hook].include? mod
    end

    def disable hook, mod
      Central.debug "Disabling hook: #{mod}##{hook}"
      toggle @hooks, @disabled_hooks, hook, mod
    end

    def enable hook, mod
      Central.debug "Disabling hook: #{mod}##{hook}"
      toggle @disabled_hooks, @hooks, hook, mod
    end

    def to_s
      @hooks.to_s
    end

    def [] key
      @hooks[key]
    end

    def each &blk
      @hooks.each &blk
    end

    def self.list
      self.instance.hooks
    end

    # Borrowing chef's knife plugin loading here
    # https://github.com/opscode/chef/blob/master/chef/lib/chef/knife/core/subcommand_loader.rb
    def self.load
      gem_hooks.each do |hook|
        Central.debug "Loading hook: #{hook}"
        Kernel.load hook
      end
    end

    private

    # Move a hook from one list to another
    # This facilitates the enabling or disabling of the hooks
    def toggle from, to, hook, mod
      to[hook] ||= []
      to[hook] << mod unless to[hook].include? mod

      Central.debug from[hook].join(", ")
      from[hook].delete mod
      Central.debug from[hook].join(", ")
    end

    def self.gem_hooks
      # search all gems for central/hook.rb
      require 'rubygems'
      find_hooks_via_rubygems
    end

    def self.find_hooks_via_rubygems
      files = Gem.find_files 'central/hook.rb'
      # TODO: Not sure how best to handle this yet
      # files.reject! {|f| from_old_gem?(f)}
      hook_files = []
      files.each do |file|
        Central.debug "Going to load: #{file}"
        hook_files << file
      end

      hook_files
    end

  end

end

# Get the hooks loaded now so they're ready for Central
Central::Hooks.load
