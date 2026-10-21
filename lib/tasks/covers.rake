# custom rake task to fetch missing covers

namespace :books do
  desc "Fetch any missing book covers from the Open Library"

  task fetch_covers: :environment do
    Book.where(cover_id: nil).find_each do |book|
      print "#{book.title}... "

      begin
        puts(book.fetch_cover! ? "found" : "no cover")

      # catch any errors if needed
      rescue OpenLibraryClient::Error => e
        puts "failed (#{e.message})"
      end

      sleep 0.5 # to avoid getting rate limited
    end
  end
end
