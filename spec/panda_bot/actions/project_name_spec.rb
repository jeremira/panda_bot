# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PandaBot::Actions::ProjectName do
  let(:name) { described_class.new 'bazok'}

  describe 'Initialize' do
    it 'instanciates itself' do
      expect(tagger).to be_a described_class
    end
  end
end
