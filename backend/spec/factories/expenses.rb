FactoryBot.define do
  factory :expense do
    description { "MyString" }
    amount { "9.99" }
    category { nil }
  end
end
