class PopulatePeriods < ActiveRecord::Migration
  def self.up
    for i in 1 .. 6
      for j in 1 .. 4
        Period.create(:year => i, :subperiod => j)
      end
    end
  end

  def self.down
    for i in 1 .. 6
      for j in 1 .. 4
        p = Period.find_by_subperiod_and_year(j,i)
        p.destroy
      end
    end
  end
end
