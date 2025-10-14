# frozen_string_literal: true

namespace :cable do
  desc "Clear all cable messages"
  task clear: :environment do
    count = SolidCable::Message.delete_all
    puts "Cleared #{count} cable messages"
  end
end
