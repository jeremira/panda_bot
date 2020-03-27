# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PandaBot::Actions::TagUuids do
  let(:tagger) { PandaBot::Actions::TagUuids.new }
  let(:agent_double) { instance_double PandaBot::Agent }
  let(:ref_task_double) { instance_double Asana::Resources::Task, notes: 'MOK-123' }

  before do
    allow(PandaBot::Agent).to receive(:new).and_return(agent_double)
    allow(agent_double).to receive(:find_task).and_return(ref_task_double)
  end

  describe 'Initialize' do
    context 'with available Uuid reference' do
      it 'instanciates itself' do
        expect(tagger).to be_a PandaBot::Actions::TagUuids
      end
      it 'exposes his agent' do
        expect(tagger.agent).to eq agent_double
      end
      it 'queries task datas from agent' do
        tagger
        expect(agent_double).to have_received(:find_task).once.with(gid: '1168601077028969')
      end
      it 'expose reference task details' do
        expect(tagger.uuid).to eq 'MOK-123'
      end
    end

    context 'without available Uuid reference' do
      let(:ref_task_double) { OpenStruct.new gid: '1168601077028969' }

      it 'raises no reference error' do
        expect { tagger }.to raise_error StandardError, 'Invalid Uuid reference from Asana : '
      end
    end

    context 'with invalid Uuid reference' do
      let(:ref_task_double) { instance_double Asana::Resources::Task, notes: 'KABOOM' }

      it 'raises no reference error' do
        expect { tagger }.to raise_error StandardError, 'Invalid Uuid reference from Asana : KABOOM'
      end
    end
  end

  describe 'add_uuid' do
    let(:tested_method) { tagger.add_uuid task }
    let(:task) do
      instance_double Asana::Resources::Task,
                      update: true,
                      custom_fields: [{ 'gid' => '1168611057004190', 'text_value' => nil }]
    end

    context 'with a valid task' do
      it 'updates the task' do
        tested_method
        expect(task).to have_received(:update).once.with(custom_fields: { '1168611057004190' => 'MOK-124' })
      end
      it 'increments the uuid' do
        tested_method
        expect(tagger.uuid).to eq 'MOK-124'
      end
      it 'returns the uuid' do
        expect(tested_method).to eq 'MOK-124'
      end
    end

    context 'without a found task' do
      it 'does not update the task' do
        tested_method
        expect(task).to have_received(:update).once.with(custom_fields: { '1168611057004190' => 'MOK-124' })
      end
      it 'increment the uuid' do
        tested_method
        expect(tagger.uuid).to eq 'MOK-124'
      end
      it 'returns the uuid' do
        expect(tested_method).to eq 'MOK-124'
      end
    end
  end
end
