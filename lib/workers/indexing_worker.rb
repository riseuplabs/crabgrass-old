class IndexingWorker < BackgrounDRb::MetaWorker
  set_worker_name :indexing_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def update_page_terms(page_id)
    logger.info 'updating page terms'
    Page.find(page_id).update_page_terms
  end
end

