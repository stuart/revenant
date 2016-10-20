defmodule GrammarTest do
  use ExUnit.Case

  test "Can parse an info line" do
    result = Revenant.Grammar.parse("2016-10-07T12:31:16 9619.625 INF Telnet connection from: 59.167.155.186:60890")
    assert {:ok,
            %{loglevel: :info, logtime: 9619.625,
              message: "Telnet connection from: 59.167.155.186:60890",
              timestamp: "2016-10-07T12:31:16",
              type: :log}} = result
  end

  test "Can't parse an empty line" do
    line = ""
    assert :mismatch = Revenant.Grammar.parse(line)
  end

  test "Can parse a chat message" do
    line = "2016-10-06T00:04:35 18812.132 INF Chat: 'Joe User': is this Alpha 15?"
    assert {:ok, %{chat: %{message: "is this Alpha 15?", user: "Joe User"}, type: :chat}} = Revenant.Grammar.parse(line)
  end

  test "Can parse a connection message" do
    line = "2016-10-06T15:04:10 72786.897 INF Player connected, entityid=236, name=Doc Saturn, steamid=11112222333334444, steamOwner=11112222333334444, ip=::ffff:59.167.155.186"
    assert {:ok,
            %{connection: %{entity_id: 236, ip: {59, 167, 155, 186},
                name: "Doc Saturn", steam_id: "11112222333334444",
                steam_owner: "11112222333334444"},
              type: :connection}} = Revenant.Grammar.parse(line)
  end

  test "Can parse a disconnection message" do
    line = "2016-10-06T15:06:21 72917.329 INF Player disconnected: EntityID=-1, PlayerID='44443333222211111', OwnerID='44443333222211111', PlayerName='Another Player'"
    assert {:ok,
            %{disconnection: %{
                name: "Another Player", steam_id: "44443333222211111"},
              type: :disconnection}} = Revenant.Grammar.parse(line)
  end

  test "Can parse a player info message" do
    line = "1. id=236, Doc Saturn, pos=(3748.8, 86.9, 3516.5), rot=(0.0, 199.7, 0.0), remote=True, health=41, deaths=9, zombies=33, players=0, score=9, level=10, steamid=44443333222211111, ip=::ffff:59.167.155.186, ping=28"
    assert {:ok,
              %{playerinfo: %{
                name: "Doc Saturn",
                position: {3748.8, 86.9, 3516.5},
                rotation: {0.0, 199.7, 0.0},
                health: 41,
                deaths: 9,
                zombie_kills: 33,
                player_kills: 0,
                level: 10,
                steam_id: "44443333222211111",
                ip: {59, 167, 155, 186},
                ping: 28
                }, type: :playerinfo}} = Revenant.Grammar.parse(line)
  end

  test "Can parse a player belt message" do
    line = "Belt of player Doc Saturn:"
    assert {:ok, %{inventory: %{name: "Doc Saturn", type: :belt}, type: :inventory}} = Revenant.Grammar.parse(line)
  end

  test "Can parse a player bag message" do
    line = "Bagpack of player Doc Saturn:"
    assert {:ok, %{inventory: %{name: "Doc Saturn", type: :bag}, type: :inventory}} = Revenant.Grammar.parse(line)
  end

  test "Can parse a player equipment message" do
    line = "Equipment of player Doc Saturn:"
    assert {:ok, %{inventory: %{name: "Doc Saturn", type: :equipment}, type: :inventory}} = Revenant.Grammar.parse(line)
  end

  test "Can parse an item line" do
    line = "Slot 0: 012 * femur"
    assert {:ok, %{item: %{name: "femur", quantity: 12, slot: 0}, type: :inventory}} = Revenant.Grammar.parse(line)
  end

  test "Can parse a parts line" do
    line = "- partsPistol_receiver - quality: 263"
    assert {:ok, %{item: %{name: "partsPistol_receiver", quantity: 263, slot: -1}, type: :inventory}} = Revenant.Grammar.parse(line)
  end

  test "Can parse an entire log capture without error" do
    {:ok, log} = File.read(__DIR__ <> "/sample_log.txt")

    String.split(log, "\n")
    |> Enum.each(fn(line) -> assert correct_parser_output(Revenant.Grammar.parse(line)) end)
  end

  def correct_parser_output({:ok, _}) do
    true
  end

  def correct_parser_output(:mismatch) do
    true
  end

  def correct_parser_output(_) do
    false
  end
end
