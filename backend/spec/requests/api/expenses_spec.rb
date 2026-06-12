require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  describe "GET /api/expenses" do
    let(:base_date) { Date.new(2026, 1, 1) }
    let!(:expense1) { Expense.create!(description: "Lunch", amount: 100.00, category: food_category, date: base_date) }
    let!(:expense2) { Expense.create!(description: "Taxi", amount: 50.00, category: transport_category, date: base_date + 1) }

    it "returns all expenses with category information" do
      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it "returns expenses in descending order by date" do
      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(expense2.id)
      expect(json.last["id"]).to eq(expense1.id)
    end

    context "when filtering by year and month" do
      let!(:other_month_expense) { Expense.create!(description: "Groceries", amount: 75.00, category: food_category, date: base_date.next_month) }

      it "returns only expenses for the specified month" do
        get "/api/expenses", params: { year: base_date.year, month: base_date.month }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        expect(json.map { |e| e["id"] }).to match_array([expense1.id, expense2.id])
      end

      it "excludes expenses from other months" do
        get "/api/expenses", params: { year: base_date.next_month.year, month: base_date.next_month.month }

        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first["id"]).to eq(other_month_expense.id)
      end

      it "returns empty when no expenses exist for the specified month" do
        get "/api/expenses", params: { year: base_date.year, month: base_date.month + 2 }

        json = JSON.parse(response.body)
        expect(json).to be_empty
      end
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq(150.5)
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
