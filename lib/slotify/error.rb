module Slotify
  class UnknownSlotError < NameError
  end

  class MissingRequiredSlotError < ArgumentError
  end

  class MultipleSlotEntriesError < ArgumentError
  end

  class SlotsAccessError < RuntimeError
  end

  class UndefinedSlotError < StandardError
  end

  class SlotArgumentError < ArgumentError
  end

  class StrictSlotsError < ArgumentError
  end
end
