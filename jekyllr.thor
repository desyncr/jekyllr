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

	desc "config", "Update configuration file."
	method_option :base_uri, :aliases => '-u', :desc => "Update Base API URI."
	method_option :oath_keys, :aliases => '-k', :desc => "Update OAuth keys."
	method_option :hostname, :aliases => '-h', :desc => "Update Hostname."
	method_option :path, :aliases => '-p', :desc => "Update path to Jekyll repo."
	method_option :all, :aliases => '-a', :desc => "Update all config fields."
	def config(*args)
		ConfigHandler.config_method_builder(args, options)
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
