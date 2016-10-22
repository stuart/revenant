defmodule Revenant.ServerSocket do
  use GenServer
  import Supervisor.Spec
  require Logger

  defstruct socket: nil, sup: nil, listeners: [], server_id: nil

  def start_link(sup, host, port, password, id) do
    GenServer.start_link(__MODULE__, {sup, host, port, password, id}, name: :"#{__MODULE__}.#{id}")
  end

  def register_listener pid, listener do
    GenServer.cast pid, {:register_listener, listener}
  end

  def deregister_listener pid, listener do
    GenServer.cast pid, {:deregister_listener, listener}
  end

  def post pid, command do
    GenServer.cast pid, {:send, command}
  end

  def say pid, message do
    GenServer.cast pid, {:say, message}
  end

  def pm pid, user, message do
    GenServer.cast pid, {:pm, user, message}
  end

  def internal_command pid, message do
    GenServer.cast pid, {:internal, message}
  end

  def init({sup, host, port, password, id}) do
    {:ok, socket} = :gen_tcp.connect(host, port, [:binary, :inet, {:packet, :line}, {:active, :false}])
    {:ok, "Please enter password:\r\n"} = telnet_recv(socket)
    :ok = :gen_tcp.send socket, password <> "\r\n"
    {:ok, login_response} = telnet_recv(socket)

    case binary_part(login_response, byte_size(login_response), -19) do
      "Logon successful.\r\n" ->
        :ok = :gen_tcp.send socket, "say \"[REVENANT] Connected and listening.\"\r\n"
        send self(), :start_listener_sup
        :timer.apply_interval(Application.get_env(:revenant, :telnet_listen_interval), GenServer, :cast, [self, :listen])
        {:ok, %__MODULE__{socket: socket, listeners: [], sup: sup, server_id: id}}

      "e enter password:\r\n" ->
        Logger.error "Incorrect password for server: #{id}"
        {:error, :password_error}

      _ ->
        Logger.error "Login failed. Unexpected response from telnet port."
        Logger.error login_response
        {:error, :unexpected_response}
    end
  end

  def handle_cast(:listen, state) do
    read_lines(state.socket, state.listeners)
    {:noreply, state}
  end

  def handle_cast({:send, command}, state) do
    :ok = :gen_tcp.send state.socket, command <> "\r\n"
    {:noreply, state}
  end

  def handle_cast({:say, message}, state) do
    :ok = :gen_tcp.send state.socket, "say \"#{message}\"\r\n"
    {:noreply, state}
  end

  def handle_cast({:pm, user, message}, state) do
    send_multiline_pm(message, user, state.socket)
    {:noreply, state}
  end

  def handle_cast({:register_listener, listener}, state) do
    {:noreply, %{state | listeners: [listener | state.listeners]}}
  end

  def handle_cast({:deregister_listener, listener}, state) do
    {:noreply, %{state | listeners: List.delete(state.listeners, listener)}}
  end

  def handle_cast({:internal, message}, state) do
    send_to_listeners(state.listeners, %{type: :internal, message: message})
    {:noreply, state}
  end

  def handle_info(:start_listener_sup, state) do
    {:ok, _pid} = Supervisor.start_child(state.sup, supervisor(Revenant.ListenerSupervisor,[self(), state.server_id], restart: :temporary))
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def terminate(reason, state) do
    :io.format("Shutting down server socket: ~p", [reason])
    |> Logger.info
    :ok = :gen_tcp.close state.socket
  end

  defp read_lines socket, listeners do
    case telnet_recv(socket) do
      {:ok, resp} ->
        case Revenant.Grammar.parse(String.strip(resp)) do
          {:ok, parsed_line} ->
            send_to_listeners(listeners, parsed_line)
          :mismatch -> true
          _ -> true
        end
        read_lines socket, listeners
      {:error, :timeout} ->
        true
    end
  end

  defp send_multiline_pm message, user, socket do
    lines = String.split(message, "\n")
    Enum.each(lines, fn(line) ->
      :ok = :gen_tcp.send socket, "pm \"#{user}\" \"#{line}\"\r\n"
    end)
  end

  defp telnet_recv socket do
    :gen_tcp.recv(socket, 0, Application.get_env(:revenant, :telnet_recv_timeout))
  end

  defp send_to_listeners listeners, message do
    Enum.each listeners, fn(%{mfa: {module, function, args}, streams: streams}) ->
      if Enum.member?(streams, message[:type]) do
        apply(module, function, args ++ [message])
      end
    end
  end
end
