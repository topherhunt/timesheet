`mkdir -p tmp/cache` # just in case this directory doesn't exist yet
Rails.cache.clear
Rails.logger.info "** Cleared the Rails cache."
puts "** Cleared the Rails cache." if Rails.env.development?
