ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap"
# Compile caches disabled: bootsnap 1.12 fails on Windows paths with accents (ENOENT bs_fetch).
Bootsnap.setup(
  cache_dir: File.expand_path('../tmp/cache', __dir__),
  development_mode: ENV.fetch('RAILS_ENV', 'development') == 'development',
  load_path_cache: true,
  compile_cache_iseq: false,
  compile_cache_yaml: false
)
