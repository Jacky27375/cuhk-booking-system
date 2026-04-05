class AuthorizationPolicy
  def self.admin_or_staff?(user)
    user&.admin? || user&.staff?
  end

  def self.admin?(user)
    user&.admin?
  end
end
