module Admin
  class CoversController < BaseController
    # POST /admin/covers 
    # This queues a cover lookup for books without covers
    def create
      ids = Book.without_cover.pluck(:id)
      ids.each { |id| FetchCoverJob.perform_later(id) }

      redirect_to admin_root_path, notice: "Looking up covers for #{ids.size} #{'book'.pluralize(ids.size)}. Refresh in a minute.", status: :see_other
    end
  end
end
