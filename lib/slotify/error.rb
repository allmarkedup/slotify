module Slotify
  class UnknownSlotError < NameError
  end

  class SlotsDefinedError < RuntimeError
  end

  class UndefinedSlotError < StandardError
  end

  class MultipleSlotEntriesError < ArgumentError
  end

  class SlotArgumentError < ArgumentError
  end

  class StrictSlotsError < ArgumentError
  end

  class ReservedSlotNameError < ArgumentError
  end
end
