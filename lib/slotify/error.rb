module Slotify
  class UnknownSlotError < NameError
  end

  class SlotError < StandardError
  end

  class SlotArgumentError < ArgumentError
  end
end
