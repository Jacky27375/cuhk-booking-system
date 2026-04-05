class BookingAccessPolicy
  def self.venue_accessible?(user, venue)
    return false unless user && venue

    Venue.visible_to_user(user).exists?(id: venue.id)
  end

  def self.equipment_accessible?(user, equipment)
    return false unless user && equipment

    Equipment.visible_to_user(user).exists?(id: equipment.id)
  end
end
