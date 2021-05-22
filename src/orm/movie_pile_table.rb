# frozen_string_literal: true

require 'sinatra/activerecord'

# sets up the database structure needed
class MoviePileTable < ActiveRecord::Migration[5.2]
  def up
    create unless ActiveRecord::Base.connection.table_exists?(:movie_piles)
  end

  def down
    drop_table :movie_piles \
      if ActiveRecord::Base.connection.table_exists?(:movie_piles)
  end

  private

  def create
    create_table :movie_piles do |table|
      table.string :name
      table.string :pile_id
      table.string :secret
      table.string :movie_list
    end
  end
end
