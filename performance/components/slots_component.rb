class Performance::SlotsComponent < ViewComponent::Base
  renders_one :description
  renders_many :items

  attr_reader :title

  def initialize(title:)
    @title = title
  end
end
