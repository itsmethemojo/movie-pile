# frozen_string_literal: true

require 'sinatra/activerecord'

# sets up the missing index on pile_id
class MoviePileTableIndex < ActiveRecord::Migration[5.2]
  def up
    add_index :movie_piles, :pile_id
  end

  def down
    remove_index :movie_piles, :pile_id
  end
end
