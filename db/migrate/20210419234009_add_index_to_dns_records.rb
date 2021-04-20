class AddIndexToDnsRecords < ActiveRecord::Migration[6.1]
  def change
    add_index :dns_records, :ip, unique: true
  end
end
