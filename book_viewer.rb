require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |paragraph, idx|
      "<p id='#{idx}'>#{paragraph}</p>"
    end.join
  end

  def apply_strong_tags(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover?(number)

  @title = "Chapter #{number}: #{chapter_name }"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  @results = find_contents(params[:query])
  erb :search
end

not_found do
  redirect "/"
end

def find_contents(query)
  return nil if query.nil? || query.strip.empty?

  (1..@contents.size).each_with_object([]) do |number, result|
    chapter = File.read("data/chp#{number}.txt")
    if chapter.include?(query)
      paragraphs = find_paragraphs(chapter, query)
      result << { number: number, name: @contents[number - 1], matches: paragraphs }
    end
  end
end

def find_paragraphs(chapter, query)
  result = []
  
  chapter.split("\n\n").each_with_index do |paragraph, idx|
    if paragraph.include?(query)
      result << { paragraph: paragraph, idx: idx }
    end
  end

  result
end
