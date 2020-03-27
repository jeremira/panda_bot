# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PandaBot::Actions::TagUuids do
  let(:tagger) { PandaBot::Actions::TagUuids.new }

  context 'with available Uuid reference' do
    it 'instanciates itself' do
      expect(tagger).to be_a PandaBot::Actions::TagUuids
    end
    it 'exposes his agent' do
      expect(tagger.agent).to be_a PandaBot::Agent
    end
    it 'queries reference task details' do
      expect(tagger.uuid).to eq 'mock_uuid1'
    end
  end
end
