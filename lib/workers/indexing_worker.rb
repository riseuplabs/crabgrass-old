class IndexingWorker < BackgrounDRb::MetaWorker
  set_worker_name :indexing_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def update_page_index(page_id)
    logger.info 'updating page index'
    Page.find(page_id).update_index
  end
end

