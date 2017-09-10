class Cacher
  # Example:
  # Cacher.fetch("user_#{user_id}_entry_#{id}_prior_entry", expires_in: 5.minutes) do
  #   ...
  # end
  def self.fetch(key, opts = {}, &block)
    Rails.cache.fetch(key, opts) do
      Rails.logger.info "Cacher: Generating cache for key \"#{key}\"."
      yield
    end
  end

  def self.delete_matched(pattern)
    Rails.logger.info "Cacher: Deleting entries matching pattern \"#{pattern}\"."
    Rails.cache.delete_matched(pattern)
  end
end
