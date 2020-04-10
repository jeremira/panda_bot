# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PandaBot::Actions::Uuids do
  let(:tagger) { described_class.new }
  let(:agent_double) { instance_double PandaBot::Agent }
  let(:ref_task_double) { instance_double Asana::Resources::Task, notes: 'MOK-123', update: true }

  before do
    allow(PandaBot::Agent).to receive(:new).and_return(agent_double)
    allow(agent_double).to receive(:find_task).and_return(ref_task_double)
  end

  describe 'Initialize' do
    context 'with available Uuid reference' do
      it 'instanciates itself' do
        expect(tagger).to be_a described_class
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

  describe 'tag!' do
    let(:tested_method) { tagger.tag! }
    let(:task1) { instance_double Asana::Resources::Task }
    let(:task2) { instance_double Asana::Resources::Task }
    let(:task3) { instance_double Asana::Resources::Task }

    before do
      allow(agent_double).to receive(:sprint_tasks).and_return(sprint_tasks_dbl)
      allow(agent_double).to receive(:backlog_tasks).and_return(backlog_tasks_dbl)
      allow(tagger).to receive(:add_uuid)
    end

    context 'with some tasks' do
      let(:sprint_tasks_dbl) { [task1, task2] }
      let(:backlog_tasks_dbl) { [task3] }

      it 'tag task1 uuid' do
        tested_method
        expect(tagger).to have_received(:add_uuid).once.with(task1)
      end

      it 'tag task2 uuid' do
        tested_method
        expect(tagger).to have_received(:add_uuid).once.with(task2)
      end

      it 'tag task3 uuid' do
        tested_method
        expect(tagger).to have_received(:add_uuid).once.with(task3)
      end

      it 'update uuid reference in database' do
        tested_method
        expect(ref_task_double).to have_received(:update).once.with(notes: 'MOK-123')
      end
    end

    context 'without any tasks' do
      let(:sprint_tasks_dbl) { [] }
      let(:backlog_tasks_dbl) { [] }

      it 'does not add any uuid' do
        tested_method
        expect(tagger).not_to have_received(:add_uuid)
      end

      it 'update uuid reference in database' do
        tested_method
        expect(ref_task_double).to have_received(:update).once.with(notes: 'MOK-123')
      end
    end
  end

  describe 'add_uuid' do
    let(:tested_method) { tagger.add_uuid task }
    let(:task) do
      instance_double Asana::Resources::Task, is_a?: true, update: true,
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

    context 'without a valid task' do
      let(:task) do
        instance_double Asana::Resources::Task, is_a?: false, update: true,
                                                custom_fields: [{ 'gid' => '1168611057004190', 'text_value' => nil }]
      end

      it 'does not update the task' do
        tested_method
        expect(task).not_to have_received(:update)
      end

      it 'does not increment the uuid' do
        tested_method
        expect(tagger.uuid).to eq 'MOK-123'
      end

      it 'returns nil' do
        expect(tested_method).to eq nil
      end
    end
  end
end
