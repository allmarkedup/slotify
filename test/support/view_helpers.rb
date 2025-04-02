module ViewHelpers
  def user_name
    "Sloty McSlotface"
  end

  def birth_date
    DateTime.new(1081,4,15).strftime("%d/%m/%Y")
  end
end
