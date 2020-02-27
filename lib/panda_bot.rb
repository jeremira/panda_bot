# frozen_string_literal: true

require 'panda_bot/version'
require 'asana'
require 'httparty'

module PandaBot
  class Error < StandardError; end
  class Agent
    attr_reader :client, :new_tasks

    WS_GID = '82576354686408' # main 'hivency' workspace gid
    TEAM_GID = '759878389278245' # main 'hivency team' workspace gid
    BACKLOG_PROJECT_GID = '1139062746771721' # backlog project gid
    SPRINT_PROJECT_GID = '1139348995392150' # sprint project gid

    def initialize
      token = ENV.fetch('ASANA_API_TOKEN', nil)
      raise 'Asana auth token not found' unless token

      @client = Asana::Client.new do |c|
        c.authentication :access_token, token
      end
    end

    #
    # Will move all Back team card from Staging to Release section in Sprint Project
    # Return PatchNote
    #
    def create_release(version)
      staged_tasks = find_back_team_tasks_from_section(staging_section.gid)
      move_those tasks: staged_tasks, to: release_section
      # generate patch notes
      report = staged_tasks.map(&:name).sort.unshift("# Hivency #{version}").join("\n - ")
      slack_message_release(version, report)
    end

    #
    # Will move all Back team card from Release to Production section in Sprint Project
    # Notify slack on #hivencyworlwide channel
    #
    def deploy_in_production(version)
      puts '------ fetching release tasks'
      release_tasks = find_back_team_tasks_from_section(prod_section.gid)
      puts '------ moving release tasks'
      move_those tasks: release_tasks, to: prod_section
      puts '------ noticing slack'
      # Warn hivency on slack
      send_slack_notification(version)
    end

    #
    # Generate Back team tech notion's reporting
    # Kind of random shit when you tired or too busy to do this shit
    #
    def create_reporting
      comings = find_back_team_tasks_from_section(todo_section.gid).first(rand(2..4)).map(&:name).join("\n")
      doings  = find_back_team_tasks_from_section(staging_section.gid).first(rand(2..4)).map(&:name).join("\n")
      dones   = find_back_team_tasks_from_section(release_section.gid).first(rand(2..4)).map(&:name).join("\n")

      File.write 'reporting.txt', ['Terminé', dones, 'En cours', doings, 'A venir', comings].join("\n")
    end

    #
    # Will create a bunch of card in Asana Backlog project
    # -- Separator mark the split between 2 tasks
    # -- check Asana API Doc to see all supported options (basicly everithing)
    #
    def create_tasks(filepath: nil, separator: '__END_OF_TASK__', options: {})
      return unless File.exist? filepath.to_s

      # -- Separator mark the split between 2 tasks
      # -- First line of the task content will be the title
      # -- Remaining will be the 'description' of the task
      # ie:
      # FOO | My title task
      # blabla blabla
      # bar foo :
      # - stuff
      # - other stuff
      # __END_OF_TASK__
      # FOO | Next task title
      # ....

      content = File.read filepath
      tasks_raw = content.strip.split separator

      tasks = tasks_raw.map do |task_raw|
        task_raw.strip.split("\n", 2)
      end

      # To add some 'custom fields (the 'source', 'squad'... labels) :
      # pass 'custom_fields' keys in the options hash with 'label id' => 'enum id' value
      # ie :
      # options : {
      #   custom_fields: {
      #     '1106632902441039' => '1106632902441040', # 'Priority' label, with 'High' value
      #     '1108446733080666' => '1108446733080667'  # 'Type de tache' label with 'Back' value
      #   }
      # }

      #
      # For references : (all ids can be found with the gem DSL)
      # Priotity Gid 1106632902441039
      # "1106632902441040"=>"Haute", "1106632902441041"=>"Moyenne", "1106632902441042"=>"Basse"
      # -- 'Type de tâche' Gid 1108446733080666
      # "1111769166317621"=>"Data",  "1108446733080667"=>"Back",  "1108446733080668"=>"Webapp Marques",  "1108446733080669"=>"Webapp Influenceurs",
      # "1108446733080670"=>"App mobile", "1142492549756599"=>"Webapps", "1142492549756600"=>"Front (toutes apps)", "1108446733080671"=>"Design",
      # "1108446733080672"=>"UX", "1108448059358204"=>"PO", "1108448059358205"=>"PM", "1126202029939940"=>"QA", "1149114806705390"=>"FUUUUUUULL STACK"
      # -- 'Source' Gid 1139062746771728
      # "1139062746771729"=>"Prod BDP", "1139062746771730"=>"Tech US", "1139062746771731"=>"Continuous",
      # "1139062746771732"=>"Roadmap", "1139476355218877"=>"Tech", "1148521528654570"=>"AC Produit",
      # "1142786259025689"=>"HotFix Release", "1158064560039243"=>"Hotfix Master"
      # -- 'Squad' Gid 1139062746771737
      # "1139062746771738"=>"Squad A", "1139062746771739"=>"Squad B",
      #

      @new_tasks = tasks.map do |task|
        params = {
          workspace: options.fetch(:workspace, WS_GID),
          projects: options.fetch(:projects, [BACKLOG_PROJECT_GID]),
          name: task.first,
          notes: task.last,
          custom_fields: options[:custom_fields]
        }
        client.tasks.create(**params)
      end
    end

    #
    # Panic button to delete all tasks created during previous #create_tasks call
    #
    def rollback!
      new_tasks.each(&:delete)
    end

    #
    # Below are used to find some specific records from Asana API
    #

    def human_readable_custom_fields
      client.custom_fields.find_by_workspace(workspace: WS_GID).map do |field|
        next unless field.resource_subtype == 'enum'

        {
          gid: field.gid,
          name: field.name,
          options: field.enum_options.map { |enum| [enum.gid.to_s, enum.name.to_s] }.to_h
        }
      end.compact
    end

    def hivency_ws
      client.workspaces.find_all.find { |ws| ws.name == 'hivency.com' }
    end

    def teams
      client.teams.find_by_organization organization: WS_GID
    end

    def find_back_team_tasks_from_section(section_gid)
      # find all tasks in this peculiar section
      tasks = client.tasks.find_by_section(section: section_gid)
      # fetch tasks details
      tasks = tasks.map { |task| client.tasks.find_by_id(task.gid) }
      # keep only back team task
      tasks.select do |task|
        task.custom_fields.any? { |field| field['gid'] && field['gid'] == '1108446733080666' && field['enum_value'] && field['enum_value']['gid'] == '1108446733080667' }
      end
    end

    def move_those(tasks:, to:)
      tasks.each do |task|
        client.post("/sections/#{to.gid}/addTask", body: { 'task' => task.gid.to_s })
      end
    end

    # Fecth and return specfic section from Sprint project
    def todo_section
      @todo_section ||= client.sections.find_by_project(project: SPRINT_PROJECT_GID).find { |section| section.name == 'Todo' }
    end

    def staging_section
      @staging_section ||= client.sections.find_by_project(project: SPRINT_PROJECT_GID).find { |section| section.name == 'Staging' }
    end

    def release_section
      @release_section ||= client.sections.find_by_project(project: SPRINT_PROJECT_GID).find { |section| section.name == 'Release' }
    end

    def prod_section
      @prod_section ||= client.sections.find_by_project(project: SPRINT_PROJECT_GID).find { |section| section.name == 'Production' }
    end


    #
    # If you dont specify channel, it will send PM to Jeremie by default.
    # Dont flood me, or do. Who I am to tell you how to live your life.
    #
    def send_slack_notification(version)
      webhook_url = 'https://hooks.slack.com/services/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'
      message = "Hivency #{version} : Deploy in production"
      HTTParty.post(webhook_url, body: { text: message, channel: 'hivencyworldwide' }.to_json, headers: {} )
    end

    def slack_message_release(version, patchnote)
      webhook_url = 'https://hooks.slack.com/services/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'
      message = "Hivency #{version} : Release creation\n ``` #{patchnote} \n```"
      HTTParty.post(webhook_url, body: { text: message, channel: 'tech' }.to_json, headers: {} )
    end
  end
end
