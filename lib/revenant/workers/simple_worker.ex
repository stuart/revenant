defmodule Revenant.Worker.State do
  defstruct user: "", socket: nil, server_id: nil, args: []
end

defmodule Revenant.Worker.SimpleBehaviour do
  @callback handle_command(%Revenant.Worker.State{}) :: any
end

# The simple worker just does one task and exits.
# It could send a message, write to the db or log something.
defmodule Revenant.Worker.Simple do
  defmacro __using__(_) do
    quote do
      @behaviour Revenant.Worker.SimpleBehaviour
      require Logger
      use GenServer
      alias Revenant.Worker.State

      def start_link(state) do
        GenServer.start_link(__MODULE__, state)
      end

      def init(state) do
        GenServer.cast self, :command
        {:ok, state}
      end

      def handle_cast(:command, state) do
        apply __MODULE__, :handle_command, [state]
        {:stop, :normal, state}
      end
    end
  end
end
