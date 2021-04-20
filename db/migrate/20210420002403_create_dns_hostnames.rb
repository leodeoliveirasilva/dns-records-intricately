class CreateDnsHostnames < ActiveRecord::Migration[6.1]
  def change
    create_table :dns_hostnames do |t|
      t.integer :dns_record_id
      t.string :hostname

      t.timestamps
    end
    add_index :dns_hostnames, :dns_record_id
  end
end
