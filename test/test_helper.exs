ExUnit.start()

# Load test helpers
Code.require_file("support/test_helpers.ex", __DIR__)

# Define mocks for external dependencies
Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)
Mox.defmock(HTTPoison, for: HTTPoison.Base)

# Define WebSocket mocks
Mox.defmock(Deepgram.Listen.WebSocket, for: GenServer)
Mox.defmock(Deepgram.Speak.WebSocket, for: GenServer)
Mox.defmock(Deepgram.Agent.WebSocket, for: GenServer)
