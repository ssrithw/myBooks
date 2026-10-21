# OpenLibrary's tagging system doesn't always correspond 
# to genre tags so this is a way to get past
# that. This is used to convert the fetched tags into genre
# tags for myBooks. Freeze is used to stop the books from
# modifying themselves again
module Genre

  # group the books by fiction and non-fiction
  FICTION = {
    "Science fiction" => /science fiction|sci-fi|space opera|cyberpunk|time travel/,
    "Fantasy" => /fantasy|magic|dragons|wizards|fairies/,
    "Dystopian fiction" => /dystopia/,
    "Horror" => /horror|ghost stories|vampires|haunted/,
    "Mystery" => /mystery|detective|whodunit|crime fiction|murder/,
    "Thriller" => /thriller|suspense|espionage|spy stories/,
    "Romance" => /romance|love stories/,
    "Historical fiction" => /historical fiction|fiction, historical/,
    "Young adult" => /young adult/,
    "Children's" => /juvenile fiction|children's stories|picture books|juvenile literature/,
    "Poetry" => /poetry|poems/,
    "Classics" => /classic literature|classics/
  }.freeze

  NON_FICTION = {
    "Biography" => /biography|autobiography|memoir/,
    "Philosophy" => /philosophy|ethics/,
    "Self-help" => /self-help|self-actualization|personal development|habits|success/,
    "Business" => /business|economics|management|finance|entrepreneur/,
    "Science" => /science|physics|biology|astronomy|cosmology|evolution|psychology/,
    "History" => /history/
  }.freeze

  FALLBACK_FICTION = "Literary fiction"

  ALL = (FICTION.keys + NON_FICTION.keys + [ FALLBACK_FICTION ]).sort.freeze

  # return genre name or nil
  def self.classify(subjects)
    tags = Array(subjects).map { |subject| subject.to_s.downcase }
    return if tags.empty?

    fiction = tags.any? { |tag| tag.match?(/fiction|novel/) }
    rules = fiction ? FICTION : FICTION.merge(NON_FICTION)

    found = rules.find { |_name, pattern| tags.any? { |tag| tag.match?(pattern) } }
    return found.first if found

    FALLBACK_FICTION if fiction
  end
end
