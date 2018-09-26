defmodule Revenant.HordeTime do
  # @horde_minutes 10080 # 7 days

  def time_to_horde_start day, hour do
    {day_diff(day, hour), hour_diff(hour)}
  end

  defp mod(a,b) when a > 0 do
    rem(a,b)
  end

  defp mod(a,b) when a < 0 do
    mod(a + b, b)
  end

  defp mod(0, _) do
    0
  end

  defp day_diff(day, hour) when hour <= 22 do
    6 - mod(day - 1 , 7)
  end

  defp day_diff(day, _hour) do
    7 - mod(day, 7)
  end

  defp hour_diff(hour) do
    mod(22 - hour, 24)
  end
end
