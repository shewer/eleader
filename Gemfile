source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in eleader.gemspec
gemspec
gem "bundler"
gem "bundle"
gem "wdm"
gem "ffi"
if RUBY_PLATFORM =~ /mingw/

  gem 'win-ffi'
  gem "win32console"
end 
gem "minitest"
gem "rspec"
gem "guard"
gem "guard-minitest"
gem "guard-bundler"
gem "guard-rspec"

gem "pry"
gem "pry-doc"
