# frozen_string_literal: true

# Follow karafka.rb config to match the consumers defined here
RSpec.shared_context 'with karafka consumer helpers' do
  let(:consumers) do
    # all_topics = ::Karafka::App.consumer_groups.map(&:topics).flat_map(&:to_a)
    Karafka::App.routes
                .reject { |cg| cg.name == 'app' || cg.name == 'karafka_web' } # We reject the default Karafka consumer
                .flat_map(&:topics).flat_map do |topics|
      topics.flat_map do |topic|
        karafka.consumer_for(topic.name)
      end
    end
  end
end
