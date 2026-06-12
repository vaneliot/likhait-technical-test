class Expense < ApplicationRecord
  belongs_to :category

  validate :date_cannot_be_in_the_future

  private

  def date_cannot_be_in_the_future
    if date.present? && date > Date.today
      errors.add(:date, "must be today or earlier")
    end
  end
end
