#require 'rest-client'
require 'json'
require 'reverse_markdown'
require 'psych'
#require 'debugger'

class TumblrToJekyll
	
	def self.basic_info
	end

	def self.convert_text_posts
		# determine post to start at
		#offset = Psych.load(File.open('.config.yml','r').read)["offset"].to_i

		#request_uri = BASE_URI + BLOG_HOSTNAME + "/posts/text?api_key=" + CONSUMER_KEY + "&offset=#{offset}"
		#response = JSON.parse(RestClient.get(request_uri))
        response = JSON.parse(File.read('data.json'))
		
        total_posts = response.keys.length#response['response']['total_posts'].to_i
		puts "#{total_posts} pulled down from Tumblr."
		
		# increment offset
		#offset += total_posts - 1
		#ConfigHandler.update_offset(offset)

		response.each do |id,  post|
            generate_jekyll_post(post)
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

    def self.generate_post_yaml(title, date, tags, url)
		yaml_hash = {layout: "post", 
		 			title: "\"#{title}\"",
		 			date: "#{date.strftime('%Y-%m-%d %k:%M:%S')}",
		 			categories: "tldr front",
		 			tags: "#{tags.join(' ')}",
                    original: "\"#{url}\""
        }
		yaml_hash.to_yaml + "---\n"
	end


    def self.generate_jekyll_post(post)
        tags = post['tags']
        date = DateTime.strptime(post['timestamp'].to_s, '%s')
        url = post['post_url']
        slug = post['slug']
        title = post['title']
        body = post['body'] || ""
        photos = post['photos']

		# navigate to _posts directory
		# start a new file 
		date_prefix = date.strftime("%Y-%m-%d")
		filename = "#{date_prefix}-#{slug}.markdown"
		system("touch #{filename}")

		# generate file content
		yaml = generate_post_yaml(title, date, tags, url)
        if post['answer']
          #body = ">#{post['question']}"
        end
		body = ReverseMarkdown.convert(body)
        body += post['answer'] if post['answer']

        if photos
          photos.each do |photo|
            body = "![](#{photo['alt_sizes'][0]['url']})\n" + body
          end
        end

		# open and write to the file
		File.open(filename, 'w') do |file|
			file.write yaml
			file.write "\n\n"
			file.write body
			file.write "\n"
			#file.write "Originally posted on [Tumblr](#{url})"
		end

		# add the file to be included in next git commit
		system("git add #{filename}")
	end
end






