RSpec::Matchers.define_negated_matcher :not_have_attributes, :have_attributes

RSpec::Matchers.define :be_within_same_day do |expected|
  match do |actual|
    expect(actual).to be_between(expected.beginning_of_day, expected.end_of_day)
  end

  def format_s(date)
    return 'nil' if date.nil?
    date.strftime('%Y-%m-%d')
  end

  failure_message do |actual|
    "expected that #{format_s(actual)} would be within the same day as #{format_s(expected)}"
  end
end