# frozen_string_literal: true

require "thor"

class Boxcar::Commands::Boxcar < Thor
  map %w[--version -v] => :__print_version

  desc "--version, -v", "print the version"
  def __print_version
    puts Boxcar::VERSION
  end

  register New, "new", "new", "create a new rails app"
end
