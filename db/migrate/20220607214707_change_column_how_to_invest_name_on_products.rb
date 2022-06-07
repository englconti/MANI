class ChangeColumnHowToInvestNameOnProducts < ActiveRecord::Migration[6.1]
  def change
    rename_column :products, :howToInvest, :how_to_invest
  end
end
