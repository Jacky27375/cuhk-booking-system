class BookingScopeQuery
  def self.for_tenant(tenant)
    scope = Booking.left_outer_joins(:venue)
    scope = scope.left_outer_joins(:equipment) if Booking.column_names.include?("equipment_id")

    venue_scope = venue_scope_for(scope, tenant)
    return venue_scope unless Booking.column_names.include?("equipment_id")

    venue_scope.or(scope.where(equipment: { tenant_id: tenant.id }))
  end

  def self.venue_scope_for(scope, tenant)
    if Venue.legacy_department_fallback_enabled?
      scope.where(venues: { tenant_id: tenant.id })
           .or(scope.where(venues: { tenant_id: nil, department: tenant.name }))
    else
      scope.where(venues: { tenant_id: tenant.id })
    end
  end
  private_class_method :venue_scope_for
end
