Ollama AI Chat Service
=======================

The Ollama AI Chat Service provides an easy way to interact with AI models for generating responses in a chat-like conversation. This README will guide you on how to use this functionality with examples.


### Using the Chat Service

Create an instance of the `Ollama::ChatService` class, which will handle the chat functionality:

```ruby
event_payload = {
  conversation_id: conversation.id,
  messages: messages
}

# From instance
chat_service = Ollama::ChatService.new(event_payload)
response = chat_service.call
# Or from call
response = Ollama::ChatService.call(event_payload)
```

This will send the messages to the AI model and generate a response. The response will be added to the conversation and the created Ollama::Message can be accessed through the `last_message` attribute of the `chat_service` instance.

```ruby
conversation = Ollama::Conversation.create! # TODO create a service
messages = [{ role: 'system', content: 'Your are a helpful assistant' }]

event_payload = {
  conversation_id: conversation.id, # optional
  message: 'hi! please send me a long message' # required
  messages: messages, # optional - represents the chat history
  model: 'mistral' # optional - please see https://github.com/ollama/ollama?tab=readme-ov-file#model-library for available models. llama3 by default.
}
chat_service = Ollama::ChatService.new(event_payload)
response = chat_service.call
# response =>
# [{"role"=>"assistant", "content"=>"Your are a helpful assistant"},
#  {:role=>"user", :content=>"hi! please send me a long message"},
#  {:role=>"assistant",
#   :content=>
#    " Hello there!\n\nI hope this message finds you well. I wanted to take a moment to share some thoughts with you, as I believe they may be of value or interest.\n\nIn our fast-paced world, it's easy to get caught up in the day-to-day hustle and bustle, forgetting to take a step back and reflect on where we are and where we want to go. But it is crucial that we do so, for only by knowing our destination can we effectively chart our course.\n\nI'd like to encourage you to think about your life's purpose, what drives you, and what you hope to achieve. What are the values and principles that guide your actions and decisions? What are the goals you want to accomplish, both in the short term and long term? Reflecting on these questions can help clarify your priorities and give direction to your efforts.\n\nIn addition to setting personal goals, I would also like to suggest taking time to develop yourself as a person. Read books that challenge you, engage in activities that stretch your comfort zone, and surround yourself with individuals who inspire and motivate you. Personal growth is an ongoing process, but the effort you put into it will pay off in many ways.\n\nAnother important aspect of living a fulfilling life is maintaining strong relationships with others. Cultivating meaningful connections with family, friends, and colleagues can bring joy, support, and enrichment to your existence. Be generous with your time, listen actively when others speak, and show empathy and compassion in your interactions.\n\nLastly, I'd like to emphasize the importance of taking care of yourself. Make sure you are eating well, getting enough sleep, exercising regularly, and finding time for relaxation and fun. A healthy mind and body are essential for optimal performance and overall happiness.\n\nIn conclusion, living a meaningful life requires setting goals, pursuing personal growth, nurturing relationships, and taking care of oneself. I hope these thoughts inspire you to reflect on your own life and make choices that lead to a more fulfilling existence.\n\nBest regards!"}]
```

This will output the AI model's generated response to the message "Hello!"


## Available Events

All custom events are within [components/ollama/app/constants/ollama/events.rb](app/constants/ollama/events.rb)

* `Ollama::Events::SYNC_EMBEDDING` will trigger the `Ollama::SyncEmbeddingService` microservice.
* `Ollama::Events::MESSAGE_CREATED` triggers an example Proc/Lambda that simple outputs to the console.
* `CHAT_STARTED` is triggered whenever a ChatService has started a chat with Ollama.
* `CHAT_STOP` is triggered whenever a ChatService has finished a chat with Ollama.

### Ollama::Message
Has all Rails Outbox triggers. Meaning, UPDATE/DESTROY/CREATE callbacks in rails are also captured and evented.


These are dynamically added but then overwritten in `Ollama::OutboxConsumer::EVENTS_MAPPING` which `MESSAGE_CREATED` and others represent as a display of functionality and extendability.


### Ollama::Conversation, Ollama::Chunk, Ollama::Event

Has all Rails Outbox triggers. Meaning, UPDATE/DESTROY/CREATE callbacks in rails are also captured and evented.
