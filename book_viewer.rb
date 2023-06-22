require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
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
  @title = "Chapter #{number}: #{chapter_name}"

  redirect "/" unless (1..@contents.size).cover?(number) 
  
  @chapter = File.read("data/chp#{number}.txt")
  
  erb :chapter, layout: :layout
end

get "/search" do
  @results = matching_chapters(params[:query])
  erb :search
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |paragraph, idx|
      "<p id=paragraph#{idx}>#{paragraph}</p/>"
    end.join
  end

  def make_bold(text, query)
    text.gsub(params[:query], "<strong>#{params[:query]}</strong>")
  end
end

def matching_chapters(query)
  results = []
  return results if query.nil? || query.strip.empty?

  # (1..@contents.size).each do |number|
  #   name = @contents[number - 1]
  #   content = File.read("data/chp#{number}.txt")
  #   result << { name: name, number: number } if content.include?(query)
  # end

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, idx|
      matches[idx] = paragraph if paragraph.include?(query)
    end

    results << { name: name, number: number, paragraphs: matches } if matches.any?
  end

  results
end

def each_chapter
  (1..@contents.size).each do |number|
    name = @contents[number - 1]
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end
