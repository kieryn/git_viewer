class GitLogJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    path = args[0]

  end
end


