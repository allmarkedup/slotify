module Slotify
  class UnknownSlotError < NameError
  end

  class MultipleSlotEntriesError < ArgumentError
  end

  class StrictSlotsError < ArgumentError
  end

  class ReservedSlotNameError < ArgumentError
  end
end
