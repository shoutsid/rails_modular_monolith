# frozen_string_literal: true

module Support
  class KarafkaConsumerMock
    def self.build(consumer, topic_name, client)
      coordinators = Karafka::Processing::CoordinatorsBuffer.new
      topic = ::Karafka::App.consumer_groups.map(&:topics).flat_map(&:to_a).find do |t|
        t.name == topic_name
      end
      consumer.topic = topic
      consumer.producer = Karafka::App.producer
      consumer.client = client
      consumer.coordinator = coordinators.find_or_create(topic.name, 0)
      consumer
    end
  end
end
