# Create new jekyll post and open in sublime
# $ ruby _new.rb This is the title

# The arguments form the title
unless ARGV[0]
  raise "Please provide a post title."
end

# Create a URL slug from the title
def slugify(title)
    str = title.dup
    str.gsub!(/[^a-zA-Z0-9 ]/,"")
    str.gsub!(/[ ]+/," ")
    str.gsub!(/ /,"-")
    str.downcase!
    str
end

# Create parameters
title  = ARGV.join(' ')
slug   = slugify(title)
prefix = Time.new.strftime("%Y-%m-%d")
file   = "#{prefix}-#{slug}.md"
path   = File.join(File.dirname(__FILE__), "_posts/#{file}")
text   = <<-eos
---
title: #{title}
layout: post
date: #{prefix}
---

eos

# Create a new file and open it in textmate
File.open(path, 'w') { |f| f.write(text) }
system("subl #{path}")