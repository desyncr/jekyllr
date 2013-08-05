require 'psych'

class ConfigHandler

	def load_config
		yaml_hash = {}
		if File.exists?('.config.yml')
			File.open('.config.yml', 'r') do |config|
				yaml_hash = Psych.load(config.read)
			end
		end
		yaml_hash
	end

	def write_to_config_file(yaml_hash)
		File.open('.config.yml', 'w') do |config|
			config.write(yaml_hash.to_yaml)
		end
	end

	def self.init_config
		config = load_config
		config["base_uri"] = "api.tumblr.com/v2/blog"
		write_to_config_file(config)
	end

	def method_missing(meth, *args, &block)
		if meth.to_s =~ /^update_(.+)$/
			update_config($1, *args, &block)
		else
			super
		end
	end

	def update_config(items, *args, &block)
		items = items.split("_and_")
		items_with_args = [items, args].transpose
		yaml_hash = Hash[items_with_args]
		
		config = load_config
		yaml_hash.each do |k, v|
			config[k] = v
		end
		write_to_config_file(config)
	end
end