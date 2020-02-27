# frozen_string_literal: true

RSpec.describe PandaBot do
  it 'has a version number' do
    expect(PandaBot::VERSION).not_to be nil
  end
end

RSpec.describe PandaBot::Agent do
  it 'instanciate itself' do
    expect(PandaBot::Agent.new).to be_a PandaBot::Asana
  end
end
