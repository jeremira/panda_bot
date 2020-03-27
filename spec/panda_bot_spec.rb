# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PandaBot do
  it 'has a version number' do
    expect(PandaBot::VERSION).not_to be nil
  end
end
