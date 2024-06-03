# frozen_string_literal: true

require 'waterdrop'
require 'karafka/testing/errors'
require 'karafka/testing/spec_consumer_client'
require 'karafka/testing/spec_producer_client'
require 'karafka/testing/rspec/proxy'

module Karafka
  module Testing
    # All the things related to extra functionalities needed to easier spec out
    # Karafka things using RSpec
    module RSpec
      # RSpec helpers module that needs to be included
      module Helpers
        def _karafka_produce(payload, metadata = {})
          # TODO: add before for destroy case
          component = JSON.parse(payload)['payload']['after']['event'].split('.').last.downcase
          topic = "#{ENV["KAFKA_CONNECT_DB_SERVER_NAME"]}_#{component}.public.#{component}_outboxes"
        end

        # Creates a consumer instance for a given topic
        #
        # @param requested_topic [String, Symbol] name of the topic for which we want to
        #   create a consumer instance
        # @param requested_consumer_group [String, Symbol, nil] optional name of the consumer group
        #   if we have multiple consumer groups listening on the same topic
        # @return [Object] Karafka consumer instance
        # @raise [Karafka::Testing::Errors::TopicNotFoundError] raised when we're unable to find
        #   topic that was requested
        #
        # @example Creates a MyConsumer consumer instance with settings for `my_requested_topic`
        #   RSpec.describe MyConsumer do
        #     subject(:consumer) { karafka.consumer_for(:my_requested_topic) }
        #   end
        def _karafka_consumer_for(requested_topic, requested_consumer_group = nil)
          selected_topics = Testing::Helpers.karafka_consumer_find_candidate_topics(
            requested_topic.to_s,
            requested_consumer_group.to_s
          )

          # raise Errors::TopicInManyConsumerGroupsError, requested_topic if selected_topics.size > 1
          raise Errors::TopicNotFoundError, requested_topic if selected_topics.empty?

          _karafka_build_consumer_for(selected_topics.first)
        end
      end
    end
  end
end
