require 'rails_helper'

describe Visit, type: :model do
  describe '.range' do
    let (:ws) { create(:workshop)}

    it 'does not return visits which are not intersected with `start` and `end`' do
      v1 = create(:visit, :started_4days_ago, :last_4days, workshop: ws)
      v2 = create(:visit, :started_4days_from_now, :last_4days, workshop: ws)

      result = Visit.range(ws, 1.day.from_now, 2.days.from_now)

      expect(result).to_not include(v1)
      expect(result).to_not include(v2)
    end

    it 'returns visits which are scheduled between `start` and `end`' do
      v1 = create(:visit, workshop: ws)

      result = Visit.range(ws, 1.week.ago, 1.week.from_now)

      expect(result).to include(v1)
    end

    it 'returns visits which start before `start` and end after `start`' do
      v1 = create(:visit, :last_4days, workshop: ws)

      result = Visit.range(ws, Date.today, 1.week.from_now)

      expect(result).to include(v1)
    end

    it 'returns visits which are scheduled before `end` and end after `end`' do
      v1 = create(:visit, :last_4days, workshop: ws)

      result = Visit.range(ws, 1.week.ago, Date.today)

      expect(result).to include(v1)
    end

    it 'returns visits which are scheduled before `start` and end after `end`' do
      v1 = create(:visit, :started_4days_ago, :last_8days, workshop: ws)

      result = Visit.range(ws, 1.day.ago, 1.day.from_now)

      expect(result).to include(v1)
    end

    it 'returns visits including the start date' do
      v1 = create(:visit, workshop: ws)

      result = Visit.range(ws, 1.day.ago, 1.day.ago)

      expect(result).to include(v1)
    end

    it 'returns visits including the end date' do
      v1 = create(:visit, workshop: ws)

      result = Visit.range(ws, 1.day.from_now, 1.day.from_now)

      expect(result).to include(v1)
    end

    it 'returns visits only for a given workshop' do
      visits = create_list(:visit, 3)

      result = Visit.range(visits[0].workshop, 1.day.ago, 1.day.from_now)

      expect(result).to include(visits[0])
      expect(result).to_not include(visits[1])
      expect(result).to_not include(visits[2])
    end
  end

  describe '#valid?' do
    let (:ws) { create(:workshop)}

    it 'should have a valid factory' do
      expect(build(:visit)).to be_valid
    end

    it 'is invalid if the end date is less then the start date' do
      expect(build(:visit, start_date: Date.today, end_date: 1.day.ago)).to_not be_valid
    end

    it 'is valid if the color is from the list of allowed colors' do
      Visit.event_colors.each do |c|
        expect(build(:visit, color: c)).to be_valid
      end
    end

    it 'is invalid if the color is not in the list of allowed colors' do
      expect(build(:visit, color: '#ffffff')).to_not be_valid
    end

    it 'is invalid if the workshop is not given' do
      expect(build(:visit, workshop: nil)).to_not be_valid
    end

    it 'is valid if the order attribute is not given' do
      expect(build(:visit, order: nil)).to be_valid
    end

    it 'is valid if the visit`s workshop match the order`s workshop' do
      o1 = build(:order, workshop: ws)
      expect(build(:visit, workshop: ws, order: o1)).to be_valid
    end

    it 'is invalid if the visit`s workshop does not match the order`s workshop' do
      expect(build(:visit, order: build(:order))).to_not be_valid
    end

    it 'notifies inconsistent error if the end date is less then the start date' do
      expect(build(:visit, start_date: Date.today, end_date: 1.day.ago).errors_on(:end_date)).
          to include(I18n.t('activerecord.errors.models.visit.date_range_invalid'))
    end

    it 'notifies inconsistent error if the visit`s workshop does not match the order`s workshop' do
      expect(build(:visit, order: build(:order)).errors_on(:workshop)).
          to include(I18n.t('activerecord.errors.models.visit.inconsistent_workshop'))
    end
  end
end
