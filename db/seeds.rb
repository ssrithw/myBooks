# Seeds 10 readers, 50 books and a shelf for every reader.
#
# Safe to run more than once: existing users, books and shelf entries are left as they are.
# Shelves are random but repeatable (fixed seed), and each reader favours two genres and rates
# those higher, so the recommendations page has something to work with straight away.
#
# Covers are looked up on Open Library at the end. Set SKIP_COVERS=1 to skip that
# (for example offline); `bin/rails books:fetch_covers` fills them in later.

# use the same password for every user
PASSWORD = "password123".freeze

READERS = [
  # in order: username, email, is_admin, favourite genres
  [ "admin", "admin@example.com", true,  [ "Classics", "History" ] ],
  [ "reader", "reader@example.com", false, [ "Science fiction", "Fantasy" ] ],
  [ "amara", "amara@example.com", false, [ "Fantasy", "Young adult" ] ],
  [ "ben_k", "ben@example.com", false, [ "Mystery", "Thriller" ] ],
  [ "chloe", "chloe@example.com", false, [ "Romance", "Classics" ] ],
  [ "dev", "dev@example.com", false, [ "Science", "Business" ] ],
  [ "elena", "elena@example.com", false, [ "Literary fiction", "Historical fiction" ] ],
  [ "farouk","farouk@example.com", false, [ "Science fiction", "Dystopian fiction" ] ],
  [ "grace", "grace@example.com", false, [ "Horror", "Mystery" ] ],
  [ "hiro", "hiro@example.com", false, [ "Philosophy", "Biography" ] ]
].freeze

# title, author, genre, year, pages, description
BOOKS = [
  [ "Dune", "Frank Herbert", "Science fiction", 1965, 412, "A young nobleman's family takes control of the desert planet Arrakis, the only source of the most valuable substance in the universe." ],
  [ "Foundation", "Isaac Asimov", "Science fiction", 1951, 255, "A mathematician predicts the fall of a galactic empire and sets out to shorten the dark age that will follow." ],
  [ "The Left Hand of Darkness", "Ursula K. Le Guin", "Science fiction", 1969, 304, "An envoy visits a wintry planet whose people have no fixed sex, and must learn to trust one of them." ],
  [ "Neuromancer", "William Gibson", "Science fiction", 1984, 271, "A washed-up hacker is hired for one last job inside a sprawling global computer network." ],
  [ "The Martian", "Andy Weir", "Science fiction", 2011, 369, "An astronaut stranded on Mars uses engineering, botany and stubbornness to stay alive." ],
  [ "Hyperion", "Dan Simmons", "Science fiction", 1989, 482, "Seven pilgrims travel to a distant world, each telling the story of what brought them there." ],
  [ "The Hobbit", "J.R.R. Tolkien", "Fantasy", 1937, 310, "Bilbo Baggins joins a company of dwarves on a quest to reclaim their treasure from a dragon." ],
  [ "The Name of the Wind", "Patrick Rothfuss", "Fantasy", 2007, 662, "A legendary figure, now an innkeeper in hiding, tells the true story of his youth." ],
  [ "A Wizard of Earthsea", "Ursula K. Le Guin", "Fantasy", 1968, 183, "A gifted young wizard unleashes a shadow on the world and must hunt it down." ],
  [ "Mistborn: The Final Empire", "Brandon Sanderson", "Fantasy", 2006, 541, "A street thief joins a crew planning to overthrow an immortal emperor using metal-fuelled magic." ],
  [ "Jonathan Strange & Mr Norrell", "Susanna Clarke", "Fantasy", 2004, 782, "Two magicians bring English magic back to life during the Napoleonic Wars, and fall out over how to use it." ],
  [ "Nineteen Eighty-Four", "George Orwell", "Dystopian fiction", 1949, 328, "Winston Smith lives under constant surveillance in a totalitarian state and begins to rebel." ],
  [ "Brave New World", "Aldous Huxley", "Dystopian fiction", 1932, 268, "A society engineered for comfort and stability leaves no room for freedom or real feeling." ],
  [ "The Handmaid's Tale", "Margaret Atwood", "Dystopian fiction", 1985, 311, "In a theocratic republic, a woman is forced to bear children for the ruling class." ],
  [ "Fahrenheit 451", "Ray Bradbury", "Dystopian fiction", 1953, 194, "A fireman whose job is burning books starts to read them." ],
  [ "The Hound of the Baskervilles", "Arthur Conan Doyle", "Mystery", 1902, 256, "Sherlock Holmes investigates a family curse and a monstrous hound on the moors." ],
  [ "And Then There Were None", "Agatha Christie", "Mystery", 1939, 272, "Ten strangers are lured to an island and killed one by one." ],
  [ "The Big Sleep", "Raymond Chandler", "Mystery", 1939, 231, "Private detective Philip Marlowe is drawn into a wealthy family's blackmail troubles in Los Angeles." ],
  [ "The Girl with the Dragon Tattoo", "Stieg Larsson", "Thriller", 2005, 465, "A journalist and a hacker look into a disappearance that happened forty years earlier." ],
  [ "Gone Girl", "Gillian Flynn", "Thriller", 2012, 419, "A woman vanishes on her fifth wedding anniversary, and her husband becomes the main suspect." ],
  [ "The Day of the Jackal", "Frederick Forsyth", "Thriller", 1971, 358, "A professional assassin is hired to kill the French president, and a detective races to find him." ],
  [ "Dracula", "Bram Stoker", "Horror", 1897, 418, "A Transylvanian count travels to England, and a small group sets out to stop him." ],
  [ "The Shining", "Stephen King", "Horror", 1977, 447, "A family looks after an isolated hotel for the winter, and the hotel works on the father." ],
  [ "The Haunting of Hill House", "Shirley Jackson", "Horror", 1959, 246, "Four people stay in a notorious house to study it; the house studies them back." ],
  [ "Pride and Prejudice", "Jane Austen", "Romance", 1813, 279, "Elizabeth Bennet and Mr Darcy misjudge each other badly before they understand each other." ],
  [ "Jane Eyre", "Charlotte Brontë", "Romance", 1847, 507, "An orphaned governess falls in love with her employer, who is hiding a secret." ],
  [ "Persuasion", "Jane Austen", "Romance", 1817, 249, "Years after being persuaded to refuse a proposal, Anne Elliot meets the man again." ],
  [ "Wolf Hall", "Hilary Mantel", "Historical fiction", 2009, 653, "Thomas Cromwell rises from blacksmith's son to Henry VIII's most powerful adviser." ],
  [ "All the Light We Cannot See", "Anthony Doerr", "Historical fiction", 2014, 531, "A blind French girl and a German orphan's paths cross in occupied France." ],
  [ "The Pillars of the Earth", "Ken Follett", "Historical fiction", 1989, 973, "The building of a cathedral in twelfth-century England over several decades." ],
  [ "To Kill a Mockingbird", "Harper Lee", "Classics", 1960, 281, "A girl in 1930s Alabama watches her father defend a Black man accused of rape." ],
  [ "Moby-Dick", "Herman Melville", "Classics", 1851, 635, "Captain Ahab pursues the white whale that took his leg." ],
  [ "Crime and Punishment", "Fyodor Dostoevsky", "Classics", 1866, 545, "A poor student commits a murder and is consumed by guilt." ],
  [ "The Great Gatsby", "F. Scott Fitzgerald", "Classics", 1925, 180, "A mysterious millionaire throws lavish parties to win back the woman he loves." ],
  [ "Beloved", "Toni Morrison", "Literary fiction", 1987, 324, "A woman who escaped slavery is haunted by the daughter she lost." ],
  [ "Never Let Me Go", "Kazuo Ishiguro", "Literary fiction", 2005, 288, "Three friends grow up at an English boarding school and slowly learn what they are for." ],
  [ "The Remains of the Day", "Kazuo Ishiguro", "Literary fiction", 1989, 245, "An English butler takes a road trip and looks back on a lifetime of service." ],
  [ "Harry Potter and the Philosopher's Stone", "J.K. Rowling", "Young adult", 1997, 223, "An orphan learns on his eleventh birthday that he is a wizard." ],
  [ "The Hunger Games", "Suzanne Collins", "Young adult", 2008, 374, "A girl volunteers to take her sister's place in a televised fight to the death." ],
  [ "Sapiens", "Yuval Noah Harari", "History", 2011, 443, "A short history of humankind, from foragers to the present." ],
  [ "Guns, Germs, and Steel", "Jared Diamond", "History", 1997, 480, "Why some societies came to dominate others, traced through geography and environment." ],
  [ "The Guns of August", "Barbara W. Tuchman", "History", 1962, 511, "The first month of the First World War and the decisions that shaped it." ],
  [ "A Brief History of Time", "Stephen Hawking", "Science", 1988, 212, "Black holes, the Big Bang and the nature of time, explained for general readers." ],
  [ "The Selfish Gene", "Richard Dawkins", "Science", 1976, 360, "Evolution seen from the point of view of the gene." ],
  [ "Thinking, Fast and Slow", "Daniel Kahneman", "Science", 2011, 499, "The two systems that drive the way we think, and where each goes wrong." ],
  [ "The Diary of a Young Girl", "Anne Frank", "Biography", 1947, 283, "The diary Anne Frank kept while hiding from the Nazis in Amsterdam." ],
  [ "Long Walk to Freedom", "Nelson Mandela", "Biography", 1994, 656, "Nelson Mandela's own account of his life, from childhood to the presidency." ],
  [ "Meditations", "Marcus Aurelius", "Philosophy", 180, 254, "Private notes on Stoic philosophy by a Roman emperor." ],
  [ "Man's Search for Meaning", "Viktor E. Frankl", "Philosophy", 1946, 165, "A psychiatrist's experiences in Nazi camps and what they taught him about purpose." ],
  [ "The Lean Startup", "Eric Ries", "Business", 2011, 336, "Building companies through quick experiments and validated learning." ]
].freeze

NOTES = {
  5 => [ "One of my all-time favourites.", "Couldn't put it down.", "Worth rereading every few years." ],
  4 => [ "Really enjoyed this one.", "Slow start, great ending.", "Would recommend." ],
  3 => [ "Good, not great.", "Some parts dragged." ],
  2 => [ "Not really for me." ],
  1 => [ "Gave up on liking it." ]
}.freeze

random = Random.new(2026)


users = READERS.map do |username, email, admin, favourites|
  user = User.find_or_create_by!(email: email) do |u|
    u.username = username
    u.password = PASSWORD
    u.is_admin = admin
  end
  [ user, favourites ]
end

# ---------- books ----------

books = BOOKS.map do |title, author, genre, year, pages, description|
  Book.find_or_create_by!(title: title, author: author) do |b|
    b.genre = genre
    b.year = year
    b.page_count = pages
    b.description = description
    b.skip_cover_fetch = true # looked up below instead of in the background
  end
end

users.each do |user, favourites|
  # skip if user exists
  next if user.user_books.exists?

  liked, other = books.partition { |book| favourites.include?(book.genre) }
  picks = liked.sample([ liked.size, 6 ].min, random: random) + other.sample(random.rand(4..7), random: random)

  picks.each_with_index do |book, index|
    favourite = favourites.include?(book.genre)
    status    = if index.zero? then "reading"
                elsif random.rand < 0.15 then "to_read"
                else "finished"
                end

    rating = if status == "finished"
               favourite ? [ 4, 5, 5 ].sample(random: random) : [ 2, 3, 3, 4 ].sample(random: random)
             end

    finished_on = Date.current - random.rand(5..300)
    user.user_books.create!(
      book: book,
      status: status,
      rating: rating,
      start: (status == "to_read" ? nil : finished_on - random.rand(7..40)),
      finish: (status == "finished" ? finished_on : nil),
      is_public: random.rand < 0.75,
      user_comment: (rating && random.rand < 0.6 ? NOTES.fetch(rating).sample(random: random) : nil)
    )
  end
end

# skip cover lookup if necessary
if ENV["SKIP_COVERS"].present?
  puts "Skipping cover lookups!"
else
  missing = Book.without_cover.to_a
  puts "Looking up #{missing.size} covers on Open Library. Use SKIP_COVERS=1 to skip." if missing.any?
  missing.each do |book|
    book.fetch_cover!
    sleep 0.3 # add a delay to prevent rate limiting
  rescue OpenLibraryClient::Error => e
    warn "  cover lookup failed for #{book.title}: #{e.message}"
  end
end

puts "Finished! Seeded #{User.count} users, #{Book.count} books and #{UserBook.count} shelf entries."
puts "Every seeded account uses the password #{PASSWORD.inspect}."
puts "admin@example.com is the admin user. Same password as above."
