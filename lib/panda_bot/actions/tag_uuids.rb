# frozen_string_literal: true

module PandaBot
  module Actions
    class TagUuids
      attr_reader :agent

      def initialize
        @agent = PandaBot::Agent.new
        @uuid = agent.find_task(id: '1168601077028969').task_notes
        # client.tasks.find_by_id('1168601077028969')&.task_notes
      end

      # uuid_field_id = '1168611057004190'
      # uuid_task = client.tasks.find_by_id '1168601077028969'
      # ref_uuid = uuid_task.notes
    end
  end
end
