require 'rails_helper'

RSpec.describe BookingsHelper, type: :helper do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end

  it "is included in the helper object" do
    expect(helper).to be_a(described_class)
  end

  describe "#booking_timetable_status_text" do
    it "returns selected for selected slots" do
      slot = { css_class: "timetable-slot-selected" }

      expect(helper.booking_timetable_status_text(slot)).to eq("Selected")
    end

    it "returns unavailable for blocked slots" do
      slot = { css_class: "timetable-slot-unavailable" }

      expect(helper.booking_timetable_status_text(slot)).to eq("Unavailable")
    end

    it "defaults to available for open slots" do
      slot = { css_class: "timetable-slot-available" }

      expect(helper.booking_timetable_status_text(slot)).to eq("Available")
    end
  end
end
