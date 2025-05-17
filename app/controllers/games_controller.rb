require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @word = params[:guess]
    @letters = params[:letters]
    start_time = Time.parse(params[:start_time])
    end_time = Time.now

    @result = run_game(@word, @letters, start_time, end_time)
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : (attempt.size * (1.0 - (time_taken / 60.0)))
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    score, message = score_and_message(attempt, grid, result[:time])
    result[:score] = score
    result[:message] = message
    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    url = "https://dictionary.lewagon.com/#{word}"
    response = URI.open(url).read
    json = JSON.parse(response)
    return json['found']
  end
end
