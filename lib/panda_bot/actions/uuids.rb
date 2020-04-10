# frozen_string_literal: true

module PandaBot
  module Actions
    #
    # Update all tasks in Backlog/Sprint project with a Uuid
    #
    class Uuids
      attr_reader :agent, :uuid

      REF_UUID_TASK_GID = '1168601077028969'
      UUID_FIELD_GID = '1168611057004190'

      def initialize
        @agent = PandaBot::Agent.new
        @uuid = agent.find_task(gid: REF_UUID_TASK_GID).notes

        raise StandardError, "Invalid Uuid reference from Asana : #{uuid}" unless /^[A-Z]{3}-\d*$/.match?(uuid.to_s)
      end

      def tag!
        puts "Fetching Sprint tasks"
        agent.sprint_tasks.each { |task| add_uuid task }
        puts "Fetching Backlog tasks"
        agent.backlog_tasks.each { |task| add_uuid task }
        puts "Updating Uuid in database"
        agent.find_task(gid: REF_UUID_TASK_GID).update(notes: uuid)
      end

      def add_uuid(task)
        puts "Updating '#{task.name}' uuid..."
        return unless task.is_a? Asana::Resources::Task
        # Uuid field is not present/empty
        return unless task.custom_fields.find { |field| field['gid'] == UUID_FIELD_GID && field['text_value'].to_s.strip.empty? }

        @uuid = uuid.gsub(/\d+/) { |match| match.to_i + 1 }
        task.update({ custom_fields: { UUID_FIELD_GID => uuid } })
        uuid
      end
    end
  end
end
