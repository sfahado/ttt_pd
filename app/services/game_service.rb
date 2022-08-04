# frozen_string_literal: true

module GameService
  def self.method_missing(klass, *args, &block) # rubocop:disable Style/MissingRespondToMissing
    "GameService::#{klass.to_s.camelize}".constantize.perform(*args, &block)
  end
end
