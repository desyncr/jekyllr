require 'psych'

class ConfigHandler

	def self.method_missing(meth, *args, &block)
		if meth.to_s =~ /^update_(.+)$/
			edit_config($1, *args, &block)
		else
			super
		end
	end

	def self.load_config
		yaml_hash = {}
		if File.exists?('.config.yml')
			File.open('.config.yml', 'r') do |config|
				yaml_hash = Psych.load(config.read)
			end
		end
		final_hash = yaml_hash.each {|k,v| k.to_sym }
	end

	def self.write_to_config_file(yaml_hash)
		File.open('.config.yml', 'w') do |config|
			config.write(yaml_hash.to_yaml)
		end
	end

	def self.init_config
		config = load_config
		config[:base_uri] = "api.tumblr.com/v2/blog"
		write_to_config_file(config)
	end

	def self.config_method_builder(*args, options)
		method_name = []
		arguments = args
		
		options.each {|k,v| options[k] = true} if options[:all]

		if options[:oath_keys]
			method_name << ["consumer_key", "secret_key"]
		elsif options[:hostname]
			method_name << "hostname"
		elsif options[:path]
			method_name << "jekyll_path"
		elsif options[:base_uri]
			method_name << "base_uri"
		end

		method_name = "update_" + method_name.flatten.join("_and_")
		send(method_name.to_sym, arguments)
	end	

	def self.edit_config(items, *args, &block)
		items = items.split("_and_")
		items_with_args = [items, args].transpose
		yaml_hash = Hash[items_with_args]
		
		config = load_config
		yaml_hash.each do |k, v|
			config[k.to_sym] = v
		end
		write_to_config_file(config)
	end
end