require "sinatra"
require "sinatra/reloader" if development?

enable :sessions

$secret_word=""
$hidden_word=""
$message = ""
$file = 'public/generic.txt'

get "/" do
	$hidden_word=""
	if $secret_word == "" then gen end
	#redirect to("/newgame")
	secretword
	erb :index
end

post "/" do
	$message = ""
	unless $secret_word.include?(params["guess"]) or $guessed.include?(params["guess"]) then $turn -= 1 end
	if $guessed.include?(params["guess"]) then $message = "You already used this letter!" else
		$guessed << params["guess"]
	end
	secretword
	if $remainingletters == 0 or $turn == 0 then redirect to("/gameover") else redirect to("/") end
end

get '/newgame' do
	$secret_word=""
	redirect to('/')
end

get "/gameover" do
	erb :gameover
end

post "/gameover" do
	$secret_word=""
	redirect to("/")
end

get "/dictionaries" do
	erb :dictionaries
end

post "/dictionaries" do
	$file = 'public/'+params["dictionaries"]+'.txt'
	$secret_word=""
	redirect to("newgame")
end

	def gen
		dictionary = Array.new
		dictionary = File.readlines($file)
		dictionary.each_with_index do |value, index|
  		dictionary[index] = dictionary[index].gsub(/\s+/, "").downcase
		end
		dictionary = dictionary.reject!{|value| value.length < 6 || value.length > 12}
		$secret_word = dictionary.sample
		$turn = 10
		$guessed = Array.new(0)
		$gameover = false
		redirect to("/")
	end

	def secretword
		$remainingletters = $secret_word.length
  	$secret_word.length.times do |i|
    	if $guessed.include? $secret_word[i] then
      	$hidden_word += "#{$secret_word[i]} " 
      	$remainingletters -= 1
 		 	  else
    	  $hidden_word += "_ "
    	end
  	end
	end