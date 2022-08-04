# frozen_string_literal: true

class ApplicationService
  def self.perform(*args, &block)
    new(*args, &block).perform
  end

  def perform
    raise 'Please define the perform method'
  end
end
