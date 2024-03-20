class Guest < ApplicationRecord
  require 'roo'

  belongs_to :event
  
  before_create :generate_rsvp_link
  
  # ===================================
  # required to have to pass Rspec tests
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :affiliation, presence: true
  validates :category, presence: true
  validates :event_id, presence: true
  validates :alloted_seats, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :commited_seats, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :guest_commited, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :allocated_seats_not_exceed_total

  def allocated_seats_not_exceed_total
    if category.present? && event.present?
      seat = event.seats.find_by(category: category)
      if seat.present?
        existing_guest = event.guests.find_by(id: self.id)
        if existing_guest.present?
          total_allocated_seats = event.guests.where(category: category).sum(:alloted_seats) - existing_guest.alloted_seats.to_i
          total_commited_seats = event.guests.where(category: category).sum(:commited_seats) - existing_guest.commited_seats.to_i
        else
          total_allocated_seats = event.guests.where(category: category).sum(:alloted_seats)
          total_commited_seats = event.guests.where(category: category).sum(:commited_seats)
        end
        remaining_allocated_seats = [0, seat.total_count - total_allocated_seats].max
        remaining_committed_seats = [0, total_allocated_seats + alloted_seats.to_i - total_commited_seats].max

        puts event.guests.where(category: category).sum(:alloted_seats)
        puts total_allocated_seats
        puts alloted_seats.to_i
        puts total_commited_seats
    
        if (total_allocated_seats + alloted_seats.to_i) > seat.total_count
          errors.add(:alloted_seats, "cannot exceed the total allocated seats (#{remaining_allocated_seats} remaining) for the category #{category}")
        end
    
        if (total_commited_seats + commited_seats.to_i) > total_allocated_seats + alloted_seats.to_i
          errors.add(:commited_seats, "cannot exceed the total allocated seats (#{remaining_committed_seats} remaining) for the category #{category}")
        end
      end
    end
    
  end


  def self.to_csv
    guests = all
    CSV.generate(headers: true) do |csv|
      cols = [:first_name, :last_name, :email, :affiliation, :perks, :comments, 
               :seat_category, :allotted, :committed, :guestcommitted, :status, :added_by]
      csv << cols
      guests.each do |guest|
        if guest.guest_seat_tickets.empty?
          csv << [guest.first_name, guest.last_name, guest.email, guest.affiliation, guest.perks, guest.comments, '', '', '', '', '', guest.user.email]
          next
        end
      
        guest.guest_seat_tickets.each do |ticket|
          user_email = guest.user.email
          gattr = guest.attributes.symbolize_keys.to_h
          gattr[:added_by] = guest.user.email
          gattr[:status] = guest.booked ? 'X' : ''
          gattr[:seat_category] = ticket.seat.category
          gattr[:allotted] = ticket.allotted
          gattr[:committed] = ticket.committed
          
          csv << gattr.values_at(*cols)
        end
      end
    end
  end
  
  def self.import_guests_csv(file, event)
    CSV.foreach(file.path, headers: true, header_converters: :symbol, converters: :all) do |row|
      first_name = row[:first_name]
      last_name = row[:last_name]
      email = row[:email]
      
      event_id = event.id
      added_by = event.user.id
      
      # Try to find an existing guest with the same email
      guest = Guest.find_or_initialize_by(email: email, event_id: event_id)
      if guest.new_record?
        # Guest.create!(first_name: first_name, last_name: last_name, email: email, added_by: added_by, event_id: event_id)
        guest.first_name = first_name
        guest.last_name = last_name
        guest.email = email
        guest.added_by = added_by
        guest.event_id = event_id
        guest.save!
      end

      
    end
  end
  # ===================================

  private

  def generate_rsvp_link
    self.rsvp_link = SecureRandom.hex(6) # You can adjust the length as needed
  end
end
