require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |paragraph, index|
      "<p id=#{index}>" + paragraph + "</p>"
    end.join
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  
  redirect "/" unless (1..@contents.size).cover? number
  
  @title = "Chapter #{number}: #{chapter_name}"
  @chp = File.read("data/chp#{number}.txt")
  erb :chapter
end

# get "/search" do
#   number_of_chapters = @contents.size
#   @search_string = params[:query]
#   if params[:query]
#     found_chapters = {}
#     (1..number_of_chapters).each do |ch_num|
#       if File.read("data/chp#{ch_num}.txt").include?(@search_string)
#         found_chapters[ch_num.to_s] = @contents[ch_num - 1]
#       end
#     end
#     if found_chapters.empty?
#       @output = "Sorry, no matches were found."
#       @switch = true
#     else
#       @output = found_chapters
#       @switch = false
#     end
#   end
#   erb :search
# end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  
  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    if contents.include?(query)
      para_numbers = []
      para_content = []
      contents.split("\n\n").each_with_index do |content, index|
        if content.include?(query)
          content = content.gsub(query, "<strong>#{query}</strong>")
          para_content << content
          para_numbers << index
        end
      end
      results << {number: number, name: name, para_numbers: para_numbers, para_content: para_content} 
    end
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end