# TransactionalOutbox Module

The `TransactionalOutbox` module is a part of our project's architecture that enables a scalable and fault-tolerant way to handle data transactions. This module is inspired by the [Transactional Outbox pattern](https://microservices.io/patterns/data/transactional-outbox.html) from Microservices.io.

**What is it?**

The `TransactionalOutbox` module provides a mechanism for handling data transactions in a distributed system. It acts as an intermediary between your application and external services, ensuring that all operations are either committed or rolled back atomically.

**How does it work?**

Whenever a Rails `update`, `destroy`, `create` events will trigger an Outbox event with the apprioriate before and after changes for that Model.

You can optionally pass an outbox event to save, which will trigger the outbox event on successful save. For example:
```ruby
my_model_instance.save!(outbox_event: 'MYEVENT')
# OR
my_model_instance.save(outbox_event: 'MYEVENT')
```


**Benefits**

By using the `TransactionalOutbox` module, you can:

* Ensure that all data transactions are either committed or rolled back, even in the presence of failures or network partitions.
* Decouple your application from external services, allowing for more robust and scalable architecture.
* Simplify error handling and retries by having a centralized mechanism for tracking and retrying failed transactions.

**How to use it**

To use the `TransactionalOutbox` module in your project:

1. Generate an outbox for your component.
```rails generate outbox:outbox YourComponentModule```

2. Run migrations
```rails db:migrate```
3. Turn rails callbacks into events by including the module into your Model
```include TransactionalOutbox::Outboxable```


**Additional resources**

For more information on the Transactional Outbox pattern, please visit [Microservices.io](https://microservices.io/patterns/data/transactional-outbox.html).

If you have any questions or need further assistance, feel free to ask!