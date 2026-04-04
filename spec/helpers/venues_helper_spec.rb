require 'rails_helper'

RSpec.describe VenuesHelper, type: :helper do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end

  it "is included in the helper object" do
    expect(helper).to be_a(described_class)
  end
end
