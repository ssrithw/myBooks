module ApplicationHelper
  COVER_TONES = 6   # used to calculate placeholder colour

  def cover_tag(book, size: "M", alt: nil)
    # convert book title to a string, calculate a 32-bit CRC checksum, 
    # then reduce the checksum to a valid int range
    # the value never changes
    # this way there's no need for an extra database value for the 
    # placeholder colours
    tone    = Zlib.crc32(book.title.to_s) % COVER_TONES
    classes = "cover cover-#{size.to_s.downcase} cover-tone-#{tone}"

    content_tag(:div, class: classes) do
      parts = [ content_tag(:span, book.title, class: "cover-fallback", aria: { hidden: true }) ]
      if (url = book.cover_url(size))
        parts << image_tag(url, alt: alt || "Cover of #{book.title}", class: "cover-img", loading: "lazy")
      end
      safe_join(parts)
    end
  end

  # rating
  def stars(rating)
    rating = rating.to_i.clamp(0, 5)
    content_tag(:span, ("★" * rating) + ("☆" * (5 - rating)),
                class: "stars", role: "img", aria: { label: "#{rating} out of 5 stars" })
  end
end
