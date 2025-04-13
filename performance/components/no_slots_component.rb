class Performance::NoSlotsComponent < ViewComponent::Base
  attr_reader :title, :description, :items

  def initialize(title:, description:, items: [])
    @title = title
    @description = description
    @items = items
  end
end
