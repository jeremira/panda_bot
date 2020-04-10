# frozen_string_literal: true

module PandaBot
  module Actions
    #
    # Generate a random acronym for your project name !
    #
    class ProjectName
      def initialize(*args)
        if args.size > 1
          puts "Project #{args.map { |arg| arg.to_s[0].upcase }.join('.')}"
          project = args.map do |arg|
            arg.to_s.size > 1 ? arg.to_s.capitalize : dico[arg.to_s.upcase.to_sym].sample.capitalize
          end
          puts project.join(' ')
        else
          puts "Project #{args[0].chars.map(&:capitalize).join('.')}"
          project = args[0].chars.map do |char|
            dico[char.upcase.to_sym].sample.capitalize
          end
          puts project.join(' ')
        end
      end

      private

      def dico
        {
          A: %w[acceptance acceptation api automatic automaton alternative amplifier assertion auth authentication active],
          B: %w[builder back backend bootstrap breaking bot big business bound],
          C: %w[change changed changing compatible complete concept compatibility compiler compilation continuous commit
                channel channelized client cloud core core credential],
          D: %w[distribution distributed database data],
          E: %w[external engine exporter export enhance enhancer event error email effective efficient effect],
          F: %w[federated file fast forwarder filter filtered fantastic],
          G: %w[generic global gate great goal],
          H: %w[hyper hold holder huge],
          I: ['id,' 'identifier', 'index', 'importer', 'import', 'instagram', 'issue', 'impossible', 'incomplete', 'international', 'intelligence',
              'infrastructure'],
          J: %w[just-in-time job java javascript job],
          K: %w[knowledge key killswitch keeper],
          L: %w[legacy large lift local localized],
          M: %w[mail mild macro micro meso mesh minifier],
          N: %w[new net network navigation navigational],
          O: %w[open object oriented organisation organised organ owner ownership],
          P: %w[publisher publication pinterest passthrough portal protocol parallel pipeline program programmatic progress
                progressive polynomial],
          Q: %w[quality qualifier quick query queue],
          R: %w[revised ruby real realtime robot rich rare],
          S: %w[sorted script side-effect small smart shift],
          T: %w[technical technology transform transformation transformation tactical ternary true task ticket token],
          U: %w[ultimate unique unsorted unknown unbounded untested],
          V: %w[virtual virtualised validation valid vector],
          W: %w[web world wide watcher watch wise],
          Z: %w[zapper zookeeper ziplok]
        }
      end
    end
  end
end
