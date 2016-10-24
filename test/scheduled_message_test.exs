defmodule ScheduledMessageTest do
  use ExUnit.Case

  test "Creating a scheduled message" do
    assert {:ok, %Revenant.Schema.ScheduledMessage{}} =
      Revenant.Schema.ScheduledMessage.create(1, "I am a scheduled message", 3000)
  end

  test "Creating a scheduled message with an invalid repeat rate" do
    assert {:error, changeset} =
      Revenant.Schema.ScheduledMessage.create(1, "I am a scheduled message", 0)

    assert [repeat_rate: _] = changeset.errors
  end
end
