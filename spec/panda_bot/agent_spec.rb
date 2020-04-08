# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PandaBot::Agent do
  let(:agent) { described_class.new }

  describe 'Initialize' do
    it 'instanciates itself' do
      expect(agent).to be_a described_class
    end

    it 'exposes his asana client' do
      expect(agent.client).to be_a Asana::Client
    end
  end

  describe '#find_task' do
    let(:tested_method) { agent.find_task(gid: 'task_id_123') }

    context 'with a succesfull call' do
      before do
        stub_request(:get, 'https://app.asana.com/api/1.0/tasks/task_id_123').to_return(
          status: 200, body: { 'data' => { 'gid' => 'task_id_123', "resource_type": 'task', "name": 'Buy catnip' } }.to_json, headers: {}
        )
      end

      it 'returns an Asana task resource' do
        expect(tested_method).to be_a Asana::Resources::Task
      end

      it 'returns relevant task' do
        expect(tested_method.gid).to eq 'task_id_123'
      end

      it 'queries informations from asana API' do
        tested_method
        assert_requested(:get, 'https://app.asana.com/api/1.0/tasks/task_id_123')
      end
    end

    context 'with a unsuccesfull call' do
      before do
        stub_request(:get, 'https://app.asana.com/api/1.0/tasks/task_id_123').to_return(
          status: 404, body: {}.to_json, headers: {}
        )
      end

      it 'returns a null object' do
        expect(tested_method).to be_an OpenStruct
      end

      it 'forwards gid arguments' do
        expect(tested_method.gid).to eq 'task_id_123'
      end

      it 'queries informations from asana API' do
        tested_method
        assert_requested(:get, 'https://app.asana.com/api/1.0/tasks/task_id_123')
      end
    end
  end

  describe '#sprint_tasks' do
    let(:tested_method) { agent.sprint_tasks }
    let(:frozen_time) { Date.new 2020, 2,3 }

    before do
      allow(Date).to receive(:today).and_return(frozen_time)
    end

    context 'with a successfull call' do
      let(:tasks_data) do
        [
          { 'gid' => 'task_id_123', "resource_type": 'task', "name": 'Buy catnip' },
          { 'gid' => 'task_id_456', "resource_type": 'task', "name": 'Buy catnap' }
        ]
      end
      before do
        stub_request(
          :get, "https://app.asana.com/api/1.0/tasks?completed_since=2020-02-02&limit=20&project=1139348995392150"
        ).to_return(status: 200, body: {'data' => tasks_data}.to_json, headers: {})
      end
      it 'queries sprint project tasks' do
        tested_method
        assert_requested(:get, "https://app.asana.com/api/1.0/tasks?completed_since=2020-02-02&limit=20&project=1139348995392150")
      end
      it 'returns an collection' do
        expect(tested_method).to be_an Asana::Collection
      end
      it 'returns all records' do
        expect(tested_method.size).to eq 2
      end
      it 'include first task' do
        expect(tested_method.find { |task| task.gid == 'task_id_123'}).to be_an Asana::Task
      end
      it 'include second task' do
        expect(tested_method.find { |task| task.gid == 'task_id_456'}).to be_an Asana::Task
      end
    end
    context 'with a successfull empty call' do
      before do
        stub_request(
          :get, "https://app.asana.com/api/1.0/tasks?completed_since=2020-02-02&limit=20&project=1139348995392150"
        ).to_return(status: 200, body: {'data' => []}.to_json, headers: {})
      end

      it 'queries sprint project tasks' do
        tested_method
        assert_requested(:get, "https://app.asana.com/api/1.0/tasks?completed_since=2020-02-02&limit=20&project=1139348995392150")
      end
      it 'returns a collection' do
        expect(tested_method).to be_an Asana::Collection
      end
      it 'returns tasks collection' do
        expect(tested_method.size).to eq 0
      end
    end
    context 'with a unsuccessfull call' do
      before do
        stub_request(
          :get, "https://app.asana.com/api/1.0/tasks?completed_since=2020-02-02&limit=20&project=1139348995392150"
        ).to_return(status: 404, body: {}.to_json, headers: {})
      end

      it 'queries sprint project tasks' do
        tested_method
        assert_requested(:get, "https://app.asana.com/api/1.0/tasks?completed_since=2020-02-02&limit=20&project=1139348995392150")
      end
      it 'returns an Array' do
        expect(tested_method).to be_an Array
      end
      it 'returns nil' do
        expect(tested_method).to eq nil
      end
    end
    context 'with a cached result' do
      before do
        tested_method
      end

      it 'does not queries again distant tasks' do
        tested_method
        #assert not requested
      end
      it 'returns tasks collection' do

      end
    end
  end
end
