defmodule Revenant.Worker.Day do
  use Revenant.Worker.Listener

  def streams do
    [:generic]
  end

  def post_request(state) do
    Revenant.ServerSocket.post state.socket, "gettime"
  end

  def handle_command(%{message: "Day " <> message, type: :generic}, state) do
    [_, day, hour, minute] = Regex.run(~r/(\d+), (\d+):(\d+)/, message)

    Revenant.ServerSocket.pm state.socket, state.user, time_message(day, hour, minute)
    :done
  end

  def handle_command(_, _) do
    nil
  end

  defp time_message(day, hour, minute) do
    daynum = String.to_integer(day)
    hournum = round(String.to_integer(hour) + String.to_integer(minute) / 60)

    {day_diff, hour_diff} = Revenant.HordeTime.time_to_horde_start(daynum, hournum)
    do_time_message(day_diff, hour_diff)
  end

  defp do_time_message(day_diff, hour_diff) when day_diff == 7 and hour_diff >= 18 do
    "[cccccc]Zombie hordes are descending on you right now! What are you doing about it?"
  end

  defp do_time_message(day_diff, hour_diff) when day_diff == 0 do
    "[cccccc]Zombie hordes arrive tonight! In approximately #{hour_diff} hours."
  end

  defp do_time_message(day_diff, hour_diff) do
    "[cccccc]Zombie hordes arrive in approximately #{day_diff} days and #{hour_diff} hours."
  end
end
