# JEKYLLR
# ================
# 
# simple script for using the Tumblr API to pull down blog posts
# format them in markdown, and post them to a Jekyll-powered site 
# hosted by GitHub pages.
# 
# Pat McGee 8/4/12

require 'rubygems'
require 'bundler/setup'

require './lib/tumblr_to_jekyll'
require './lib/config_handler'

class Jekyllr < Thor

	desc "init_config", "Initialize configuration file."
	def init_config
		ConfigHandler.init_config
		puts "Configutation file initialized."
	end

	desc "update_config", "Update configuration file."
	method_option :base_uri, :aliases => '-u', :desc => "Update Base API URI."
	method_option :no_oath_keys, :aliases => '-k', :desc => "Don't update OAuth keys."
	method_option :no_hostname, :aliases => '-h', :desc => "Don't update Hostname."
	method_option :no_path, :aliases => '-p', :desc => "Don't update path to Jekyll repo."
	def update_config
		method_name = []
		args = []
		unless options[:no_oath_keys]
			puts "Consumer Key: "
			args << gets.chomp
			puts "Secret Key: "
			args << gets.chomp
			method_name << ["consumer_key", "secret_key"]
		end

		unless options[:no_hostname]
			puts "Hostname: "
			args << gets.chomp
			method_name << "hostname"
		end
		
		unless options[:no_path]
			puts "Absolute Path to Jekyll Repo: "
			args << gets.chomp
			method_name << "jekyll_path"
		end

		if options[:base_uri]
			puts "Base API URI: "
			args << gets.chomp
			method_name << "base_uri"
		end

		method_name = "update_" + method_name.flatten.join("_and_")
		ConfigHandler.send(method_name.to_sym, args)
	end

	desc "info", "See basic information about your blog."
	def info
		TumblrToJekyll.basic_info
	end

	desc "transfer", "Transfer posts from Tumblr to Jekyll blog"
	def transfer
		TumblrToJekyll.convert_text_posts
	end

end
