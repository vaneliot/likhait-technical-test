require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:category) { Category.create!(name: "Food") }
  let(:expense) { Expense.new(description: "Snacks", amount: 10.00, category: category, date: date) }

  describe "validations" do
    context "with today's date" do
      let(:date) { Date.today }
      it { expect(expense).to be_valid }
    end

    context "with a date from the past" do
      let(:date) { Date.yesterday }
      it { expect(expense).to be_valid }
    end

    context "with a date from the future" do
      let(:date) { Date.tomorrow }

      it "is invalid" do
        expect(expense).not_to be_valid
        expect(expense.errors[:date]).to include("must be today or earlier")
      end
    end
  end
end
