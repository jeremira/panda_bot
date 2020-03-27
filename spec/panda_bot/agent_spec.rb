# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PandaBot::Agent do
  let(:agent) { PandaBot::Agent.new }

  describe 'Initialize' do
    it 'instanciates itself' do
      expect(agent).to be_a PandaBot::Agent
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
end
