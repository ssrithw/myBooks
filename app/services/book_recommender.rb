# This file houses the algorithm used to recommend 
# books to readers.
#
# The algorithm works as follows: 
# When a reader rates a book, a score is added to the genre
# 5 stars = 2 points, 4 stars = 1 point, 3 stars = 0.25 points
# 2 stars = -1 points, 1 star = -2 points
#
# Any genre with a score above 0 is considered a "liked" genre.
# Unshelved books are weighted as follows:
# (genre) + (damped rating - 3)
# where the community rating is damped using bayesian weighted rating
#
# A fallback option is provided by way of all of the best-rated 
# books outside of the disliked genres.

class BookRecommender
  # weights used by the algorithm, as described above
  RATING_WEIGHTS = { 5 => 2.0, 4 => 1.0, 3 => 0.25, 2 => -1.0, 1 => -2.0 }.freeze
  NEUTRAL_RATING = 3.0 # corresponds to m in damped_rating
  PRIOR_RATINGS  = 2  # corresponds to C damped_rating
  # n is the number of real ratings

  # create a small class to hold the following
  # book (the recommendation)
  # reason (simple explanation for the rec)
  # score (used to sort recommendations)
  # personal (boolean to determine if recommendations are from the algorithm or fallback)
  Pick = Data.define(:book, :reason, :score, :personal) do
    # lets views check if recommendations are personalized
    alias_method :personal?, :personal
  end

  def initialize(user, limit: 12)
    @user  = user
    @limit = limit # max number of picks (recommendations)
  end

  def call
    personal = genre_picks # personalized based on algorithm
    personal + fallback_picks(exclude: personal.map { |pick| pick.book.id }) # fallback highest-rated options
  end

  # becomes true when a user rates a book in that genre
  def personalised?
    genre_weights.any? { |_genre, weight| weight.positive? }
  end

  
  private

  attr_reader :user, :limit

  # used to select the personalized recommendations
  def genre_picks
    # only keep genres with a positive score
    liked = genre_weights.select { |_genre, weight| weight.positive? }
    return [] if liked.empty?
    # get all possible candidates
    candidates = unshelved_books.where("LOWER(books.genre) IN (?)", liked.keys).to_a
    # add all candidates to a map and return real average rating for all of them
    stats = community_stats(candidates.map(&:id))

    candidates.map { |book|
      genre = book.genre.downcase
      # build the pick, score it as described above, then sort by
      # highest score > no of ratings > titles in alphabetical order 
      Pick.new(book: book, reason: reason_for(genre),
               score: liked[genre] + (damped_rating(stats[book.id]) - NEUTRAL_RATING),
               personal: true)
    }.sort_by { |pick| [ -pick.score, -stats.dig(pick.book.id, :count).to_i, pick.book.title ] }.first(limit)
  end

  def fallback_picks(exclude:)
    # blank places left after the personal picks
    room = limit - exclude.size
    return [] unless room.positive?

    # note disliked genres, don't pick from these
    disliked   = genre_weights.select { |_genre, weight| weight.negative? }.keys
    # get all possible candidates, including genreless books
    candidates = unshelved_books.where.not(id: exclude)
    candidates = candidates.where("books.genre IS NULL OR LOWER(books.genre) NOT IN (?)", disliked) if disliked.any?
    candidates = candidates.to_a
    # add all candidates to a map and return real average rating for all of them
    stats = community_stats(candidates.map(&:id))

    candidates.map { |book|
      stat = stats[book.id]
      # build the pick, score it as described above, then sort by
      # highest score > no of ratings > titles in alphabetical order 
      # unrated books receive a neutral score and are labelled "new to the catalogue"
      Pick.new(book: book,
               reason: stat ? "Rated #{stat[:average].round(1)} by #{stat[:count]} #{'reader'.pluralize(stat[:count])}" : "New to the catalogue",
               score: damped_rating(stat), personal: false)
    }.sort_by { |pick| [ -pick.score, -stats.dig(pick.book.id, :count).to_i, pick.book.title ] }
     .first(room)
  end

  # all genres start at score 0, cache the result
  def genre_weights
    @genre_weights ||= rated_entries.each_with_object(Hash.new(0.0)) do |entry, weights|
      genre = entry.book.genre.to_s.downcase
      weights[genre] += RATING_WEIGHTS.fetch(entry.rating, 0.0) if genre.present?
    end
  end

  # get all the books this user has rated
  def rated_entries
    @rated_entries ||= user.user_books.where.not(rating: nil).includes(:book).to_a
  end

  # user's highest-rated book in a genre. used for the 
  # "because you rated x" reasoning, sorted by most recent
  def reason_for(genre)
    best = rated_entries.select { |entry| entry.book.genre.to_s.downcase == genre }
                        .max_by { |entry| [ entry.rating, entry.updated_at ] }
    "Because you rated #{best.book.title} #{best.rating}★ (#{best.book.genre})"
  end

  # SQL query for books not in user's shelf, used to find potential picks
  def unshelved_books
    Book.where.not(id: user.user_books.select(:book_id))
  end

  # SQL query to return the real average rating of a book
  def community_stats(book_ids)
    return {} if book_ids.empty? # skip if no book is found

    UserBook.where(book_id: book_ids).where.not(rating: nil).group(:book_id)
            .pluck(:book_id, Arel.sql("AVG(rating)"), Arel.sql("COUNT(*)"))
            .to_h { |id, average, count| [ id, { average: average.to_f, count: count } ] }
  end

  # to ensure a fairer rating system, we use the bayesian average formula 
  # with fixed C and m to compensate for books with low/no ratings
  # (C * m + sum of ratings) / (C + n)
  # ie.
  # (prior ratings * 3.0 + sum of ratings) / (prior ratings + real ratings)
  # for a book with one 5 star review:
  # ((5*1) + (3*2)) / (2 + 1) = ~3.67
  def damped_rating(stat)
    # weight books with no rating as neutral
    return NEUTRAL_RATING unless stat
    (stat[:average] * stat[:count] + NEUTRAL_RATING * PRIOR_RATINGS) / (stat[:count] + PRIOR_RATINGS)
  end
end
