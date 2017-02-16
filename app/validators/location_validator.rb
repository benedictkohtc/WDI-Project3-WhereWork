class LocationValidator < ActiveModel::Validator
  def validate(record)
    unless record.available_sockets > -1
      record.errors[:available_sockets] << 'Available sockets need to be 0 or more please.'
    end
    unless record.available_seats > -1
      record.errors[:available_seats] << 'Available seats need to be 0 or more please.'
    end
  end
end
