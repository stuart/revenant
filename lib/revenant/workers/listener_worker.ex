defmodule Revenant.Worker.ListenerBehaviour do
  @callback handle_command(Map, %Revenant.Worker.State{}) :: any
  @callback post_request(%Revenant.Worker.State{}) :: any
  @callback streams() :: [Atom]
end

# The listener worker registers itself with the ServerSocket on the streams given
# in the streams() callback.
# post_request() gets called on initialization to send a message
# to the game server, which we want to wait for a reply to.
#
# handle_command() callback when a message is recieved on one of the streams.
# It should return :done when it has gotten the message it is interested in
# and completed it's work.
#
# Listener workers will timeout and die if they do not recieve a message
# for which handle_command returns :done

defmodule Revenant.Worker.Listener do
  defmacro __using__(_) do
    quote do
      @behaviour Revenant.Worker.ListenerBehaviour

      require Logger
      use GenServer
      alias Revenant.Worker.State

      def start_link(state) do
        GenServer.start_link(__MODULE__, state)
      end

      def command(pid, message) do
        GenServer.cast(pid, {:command, message})
      end

      def init(state) do
        Revenant.ServerSocket.register_listener state.socket, listener_mfa
        apply(__MODULE__, :post_request, [state])
        Process.send_after(self, :timeout, Application.get_env(:revenant, :worker_timeout))
        {:ok, state}
      end

      def terminate(_,state) do
        Revenant.ServerSocket.deregister_listener state.socket, listener_mfa
        :ok
      end

      def handle_cast({:command, message},state) do
        case apply(__MODULE__, :handle_command, [message, state]) do
          :done -> {:stop, :normal, state}
          _ -> {:noreply, state}
        end
      end

      def handle_info(:timeout, state) do
        Logger.warn "#{__MODULE__} timed out without receiving response."
        {:stop, :normal, state}
      end

      def handle_info(_, state) do
        {:noreply, state}
      end

      def listener_mfa do
        %{mfa: {__MODULE__, :command, [self]}, streams: apply(__MODULE__, :streams, [])}
      end
    end
  end
end
