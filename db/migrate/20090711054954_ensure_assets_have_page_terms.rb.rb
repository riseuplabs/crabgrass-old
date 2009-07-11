#
# When I upgraded a couple old databases, the assets did not have page terms. This migration
# will fix this problem when migrating from older schema.
# 
class EnsureAssetsHavePageTerms < ActiveRecord::Migration
  def self.up
    Asset.all.each do |asset|
      if asset.page_terms_id.nil? and asset.page and asset.page.page_terms
        Asset.connection.execute('UPDATE assets SET page_terms_id = %s WHERE id = %s' % [asset.page.page_terms.id, asset.id])
        putc '.'; STDOUT.flush
      end
    end
  end

  def self.down
  end
end

