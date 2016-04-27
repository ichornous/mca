require 'rails_helper'

describe Visit, type: :model do
  describe '.range' do
    it 'does not return visits which are not intersected with `start` and `end`' do
      # setup
      v1 = create(:visit)
      puts "#{v1.start_date} - #{v1.end_date}"
      v2 = create(:visit, :in_the_past)
      puts "#{v2.start_date} - #{v2.end_date}"
      v3 = create(:visit, :in_the_future, :long)
      puts "#{v3.start_date} - #{v3.end_date}"

      # exercise
      # verify
    end

    it 'returns visits which are scheduled between `start` and `end`'
    it 'returns visits which are scheduled before `start` and end after `start`'
    it 'returns visits which are scheduled before `end` and end after `end`'
    it 'does not return cancelled visits'
  end

  describe '#valid?' do
    it 'is invalid if the end date is less then the start date'
    it 'is invalid if the color is not in the list of allowed colors'
    it 'is invalid if the workshop is not given'
    it 'is valid if the order attribute is not given'
    it 'is invalid if the visit`s workshop does not match the order`s workshop'
  end
end
