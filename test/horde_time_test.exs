defmodule HordeTimeTest do
  use ExUnit.Case

  test "it should show the time to horde start" do
    assert {0,0} = Revenant.HordeTime.time_to_horde_start 7, 22
    assert {0,0} = Revenant.HordeTime.time_to_horde_start 21, 22
    assert {1,6} = Revenant.HordeTime.time_to_horde_start 6, 16
    assert {6,18} = Revenant.HordeTime.time_to_horde_start 1, 4
    assert {7, 23} = Revenant.HordeTime.time_to_horde_start 28, 23
    assert {0, 1} = Revenant.HordeTime.time_to_horde_start 7, 21
  end
end
