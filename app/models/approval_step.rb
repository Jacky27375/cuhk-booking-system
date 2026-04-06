class ApprovalStep < ApplicationRecord
  ACTIONS = %w[start_review approve reject cancel].freeze

  belongs_to :booking
  belongs_to :actor, class_name: "User", inverse_of: :approval_steps

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :from_status, presence: true, inclusion: { in: ->(_) { Booking.statuses.keys } }
  validates :to_status, presence: true, inclusion: { in: ->(_) { Booking.statuses.keys } }
  validates :reason, length: { maximum: 500 }, allow_blank: true
end
