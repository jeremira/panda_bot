# frozen_string_literal: true

module PandaBot
  module Actions
    class Uuids
      attr_reader :agent, :uuid

      def initialize
        @agent = PandaBot::Agent.new
        @uuid = agent.find_task(gid: '1168601077028969').notes

        raise StandardError, "Invalid Uuid reference from Asana : #{uuid}" unless /^[A-Z]{3}-\d*$/.match?(uuid.to_s)
      end

      def tag!
        agent.sprint_tasks.each { |task| add_uuid task }
        agent.backlog_tasks.each { |task| add_uuid task }
        agent.find_task(gid: '1168601077028969').update(notes: ref_uuid)
      end
      #
      # def hivency_tasks
      #   SPRINT_PROJECT_GID = '1139348995392150' # sprint project gid
      #   BACKLOG_PROJECT_GID = '1139062746771721' #
      #   client.tasks.find_all(project: SPRINT_PROJECT_GID)
      #   client.tasks.find_all(project: BACKLOG_PROJECT_GID)
      # end

      def add_uuid(task)
        return unless task.is_a? Asana::Resources::Task
        return unless task.custom_fields.find { |f| f['gid'] == '1168611057004190' && f['text_value'].to_s.strip.empty? }

        @uuid = @uuid.gsub(/\d+/) do |match|
          match.to_i + 1
        end
        task.update({ custom_fields: { '1168611057004190' => @uuid } })

        uuid
      end
    end
  end
end
#
# task.subtasks.each do |task|
#   puts "updating sub task : #{task.name}"
#   task = client.tasks.find_by_id(task.gid)
#
#   next if pas Asana task
#   next unless task.custom_fields.find { |f| f['gid'] == '1168611057004190' && f['text_value'].to_s.strip.empty? }
#
#   ref_uuid = ref_uuid.gsub(/\d+/) do |match|
#     match.to_i + 1
#   end
#   task.update({ custom_fields: { uuid_field_id => ref_uuid } })
# end
#   uuid_task.update(notes: ref_uuid)
