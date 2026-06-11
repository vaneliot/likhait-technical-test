require 'rails_helper'

RSpec.describe "Api::Categories", type: :request do
  describe "GET /api/categories" do
    let!(:food) { Category.create!(name: "Food") }
    let!(:transport) { Category.create!(name: "Transport") }
    let!(:supplies) { Category.create!(name: "Supplies") }

    it "returns all categories" do
      get "/api/categories"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.map { |c| c["name"] }).to include("Food", "Transport", "Supplies")
    end

    it "returns categories in alphabetical order" do
      get "/api/categories"

      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to eq([ "Food", "Supplies", "Transport" ])
    end
  end

  describe "POST /api/categories" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          category: {
            name: "Subscriptions"
          }
        }
      end

      it "creates a new category" do
        expect {
          post "/api/categories", params: valid_params, as: :json
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Subscriptions")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity when name is nil" do
        invalid_params = {
          category: {
            name: nil,
          }
        }

        post "/api/categories", params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when name already exists" do
      let(:category_name) { "Subscriptions" }

      before { Category.create!(name: category_name) }

      it "returns unprocessable entity" do
        post "/api/categories", params: { category: { name: category_name } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end
end
