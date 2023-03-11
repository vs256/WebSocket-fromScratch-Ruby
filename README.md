# WebSocket-fromScratch-Ruby
Building WebSockets from scratch in Ruby without using any pre-defined libraries.

## Overview
Basic implementation of a WebSocket server that takes messages from a client and sends them back with a thank you.

### Pseudocode

```
server = WebsocketServer.new

loop do
  Thread.new(server.accept) do |connection|
    puts "Connected"
    while (message = connection.recv)
      puts "Received #{message}"
      connection.send("Received #{message}. Thanks!")
    end
  end
end
```

## Planned Work
- Ping/Pong heartbeats
- Types of messages that aren’t UTF-8 text data
- Security
- Proxying
- Handling different WebSocket protocol versions
- Message fragmentation.