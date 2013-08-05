# JEKYLLR
# ================
# 
# simple script for using the Tumblr API to pull down blog posts
# format them in markdown, and post them to a Jekyll-powered site 
# hosted by GitHub pages.
# 
# Pat McGee 8/4/12
require 'json'
require 'rest-client'
require 'reverse_markdown'
require 'psych'

require 'config_handler'

module TumblrToJekyll
	# OAuth 
	
	config = {}
	
	File.open("../.config.yml", "r") do |file|
		config = Psych.load(file.read)
	end

	CONSUMER_KEY = config["consumer_key"]
	SECRET_KEY = config["secret_key"]

	BASE_URI = config["base_uri"]
	BLOG_HOSTNAME = config["hostname"]

	JEKYLL_PATH = config["jekyll_path"]



	def basic_info
		request_uri = BASE_URI + BLOG_HOSTNAME + "/info?api_key=" + CONSUMER_KEY
		response = JSON.parse(RestClient.get(request_uri))
		response = response['response']['blog']
		puts """
				Title: #{response['title']}
				Name: #{response['name']}
				Description: #{response['description']}

				Number of Posts: #{response['posts']}
				Number of Likes: #{response['likes']}

				Last Updated: #{DateTime.strptime(response['updated'].to_s, '%s')}

				Ask / Anon: #{response['ask']} / #{response['ask_anon']}
			"""
	end

	def convert_text_posts
		# determine post to start at
		offset = Psych.load(File.open('.config.yml','r').read)["offset"].to_i

		request_uri = BASE_URI + BLOG_HOSTNAME + "/posts/text?api_key=" + CONSUMER_KEY + "&offset=#{offset}"
		response = JSON.parse(RestClient.get(request_uri))

		
		total_posts = response['response']['total_posts'].to_i
		puts "#{total_posts} pulled down from Tumblr."
		
		# increment offset
		offset += total_posts - 1
		ConfigHandler.update_offset(offset)

		response = response['response']['posts']

		response.each do |post|
			tags = post['tags']
			date = DateTime.strptime(post['timestamp'].to_s, '%s')
			url = post['post_url']
			slug = post['slug']
			title = post['title']
			body = post['body']
			generate_jekyll_post(tags: tags, date: date, url: url, slug: slug, title: title, body: body)
		end

	end

	#  YAML HEADER
	# ---
	# layout:
	# title:
	# date:
	# categories:
	# tags:
	# ---

	def generate_post_yaml(title, date, tags)
		yaml_hash = {layout: "post", 
		 			title: "\"#{title}\"",
		 			date: "#{date.strftime('%Y-%m-%d %k:%M:%S')}",
		 			categories: "tldr front",
		 			tags: "#{tags.join(' ')}"}
		yaml_hash.to_yaml + "---\n"
	end


	def generate_jekyll_post(options={})
		# navigate to _posts directory
		Dir.chdir(JEKYLL_PATH) unless Dir.pwd == JEKYLL_PATH

		# start a new file 
		date_prefix = options[:date].strftime("%Y-%m-%d")
		filename = "#{date_prefix}-#{options[:slug]}.markdown"
		system("touch #{filename}")

		# generate file content
		yaml = generate_post_yaml(options[:title], options[:date], options[:tags])
		body = ReverseMarkdown.parse(options[:body])

		# open and write to the file
		File.open(filename, 'w') do |file|
			file.write yaml
			file.write "\n\n"
			file.write body
			file.write "\n\n"
			file.write "Originally posted on [Tumblr](#{options[:url]})"
		end

		# add the file to be included in next git commit
		system("git add #{filename}")
	end
end






