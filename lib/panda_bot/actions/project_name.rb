# frozen_string_literal: true

module PandaBot
  module Actions
    #
    # Generate a random acronym for your project name !
    #
    class ProjectName

      def initialize(*args)
        puts "Project #{args.map{ |arg| arg.to_s[0].upcase }.join('.')}"
        project = args.map do |input|
          input.to_s.size > 1 ? input.capitalize : dico[char.upcase.to_sym].sample.capitalize
        end
        puts project.join(' ')
      end

      private

      def dico
        {
          A: [ 'acceptance', 'acceptation', 'api', 'automatic', 'automaton', 'alternative', 'amplifier', 'assertion', 'auth', 'authentication', 'active'],
          B: [ 'builder', 'back', 'backend', 'bootstrap', 'breaking', 'bot', 'big', 'business', 'bound'],
          C: [ 'change', 'changed', 'changing', 'compatible', 'complete', 'concept', 'compatibility', 'compiler', 'compilation', 'continuous', 'commit', 'channel', 'channelized', 'client', 'cloud', 'core', 'core', 'credential'],
          D: [ 'distribution', 'distributed', 'database', 'data'],
          E: [ 'external', 'engine', 'exporter', 'export', 'enhance', 'enhancer', 'event', 'error', 'email', 'effective', 'efficient', 'effect'],
          F: [ 'federated', 'file', 'fast', 'forwarder', 'filter', 'filtered', 'fantastic'],
          G: [ 'generic', 'global', 'gate', 'great', 'goal'],
          H: [ 'hyper', 'hold', 'holder', 'huge'],
          I: [ 'id,' 'identifier', 'index', 'importer', 'import', 'instagram', 'issue', 'impossible', 'incomplete', 'international', 'intelligence', 'infrastructure'],
          J: [ 'just-in-time', 'job', 'java', 'javascript', 'job'],
          K: [ 'knowledge', 'key', 'killswitch', 'keeper'],
          L: [ 'legacy', 'large', 'lift', 'local', 'localized' ],
          M: [ 'mail', 'mild', 'macro', 'micro', 'meso', 'mesh', 'minifier' ],
          N: [ 'new', 'net', 'network', 'navigation', 'navigational' ],
          O: [ 'open', 'object', 'oriented', 'organisation', 'organised', 'organ', 'owner', 'ownership' ],
          P: [ 'publisher', 'publication', 'pinterest', 'passthrough', 'portal', 'protocol', 'parallel', 'pipeline', 'program', 'programmatic', 'progress', 'progressive', 'polynomial' ],
          Q: [ 'quality', 'qualifier', 'quick', 'query', 'queue' ],
          R: [ 'revised', 'ruby', 'real', 'realtime', 'robot', 'rich', 'rare' ],
          S: [ 'sorted', 'script', 'side-effect', 'small', 'smart', 'shift' ],
          T: [ 'technical', 'technology', 'transform', 'transformation', 'transformation', 'tactical', 'ternary', 'true' , 'task', 'ticket', 'token' ],
          U: [ 'ultimate', 'unique', 'unsorted', 'unknown', 'unbounded', 'untested' ],
          V: [ 'virtual', 'virtualised', 'validation', 'valid', 'vector' ],
          W: [ 'web', 'world', 'wide', 'watcher', 'watch', 'wise' ],
          Z: [ 'zapper', 'zookeeper', 'ziplok' ]
        }
      end
    end
  end
end
