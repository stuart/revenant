defmodule Revenant.Grammar do
  use Neotomex.ExGrammar

  @root true
  define :message_line, "( inventoryline / itemline / connectionline / disconnectionline / chatline / logline /playerinfoline / generic) <eol?>" do
    [f] -> f
  end

  # Chat log messages
  define :chatline, "preamble chat_message" do
    [[timestamp, logtime, loglevel], message] -> %{type: :chat, timestamp: timestamp, loglevel: loglevel, logtime: logtime, chat: message}
  end

  # Player connected messages
  define :connectionline, "preamble connection_message" do
    [[timestamp, logtime, loglevel], message] -> %{type: :connection, timestamp: timestamp, loglevel: loglevel, logtime: logtime, connection: message}
  end

  # Player disconnected messages
  define :disconnectionline, "preamble disconnection_message" do
    [[timestamp, logtime, loglevel], message] -> %{type: :disconnection, timestamp: timestamp, loglevel: loglevel, logtime: logtime, disconnection: message}
  end

  # General log messages
  define :logline, "preamble .+" do
    [[timestamp, logtime, loglevel], message] -> %{type: :log, timestamp: timestamp, loglevel: loglevel, logtime: logtime, message: Enum.join(message)}
  end

  define :playerinfoline, "<digit+> <'. id='> <digit+> <','> <space> string_val <','> <space> keyvallist" do
    [user, keyval] -> m = Map.new(keyval)
      %{ playerinfo: %{name: user, position: m["pos"], rotation: m["rot"], health: m["health"], deaths: m["deaths"],
        zombie_kills: m["zombies"], player_kills: m["players"], score: m["score"], level: m["level"],
        steam_id: Integer.to_string(m["steamid"]), ip: m["ip"], ping: m["ping"]},
         type: :playerinfo
       }
  end

  define :inventoryline, "belt / bag / equipment" do
    inventory -> %{type: :inventory, inventory: inventory}
  end

  define :itemline, "item / part" do
    item -> %{type: :inventory, item: item}
  end

  # Generic non log messages such as replies to commands
  define :generic, "<!preamble> .+" do
    [message] -> %{type: :generic, message: Enum.join(message)}
  end

  define :chat_message, "<'Chat: '> <quot> (<!quot> .)* <quot> <':'> <space> .*" do
    [username, message] -> %{user: Enum.join(username), message: Enum.join(message)}
  end

  define :bag, "<'Bagpack of player '> (<!':'> .)* <':'>" do
    [name] ->
      %{name: Enum.join(name), type: "bag"}
  end

  define :belt, "<'Belt of player '> (<!':'> .)* <':'>" do
    [name] ->
      %{name: Enum.join(name), type: "belt"}
  end

  define :equipment, "<'Equipment of player '> (<!':'> .)* <':'>" do
    [name] -> %{name: Enum.join(name), type: "equipment"}
  end

  define :item, "<'Slot '> number <': '> number <' * '> .+" do
    [slot, quantity, item] -> %{slot: slot, quantity: quantity, name: Enum.join(item)}
  end

  define :part, "<'- '> (<!' '> .)* <' - quality: '> number" do
    [item, quantity] -> %{slot: -1, quantity: quantity, name: Enum.join(item)}
  end

  define :connection_message, "<'Player connected, '> keyvallist" do
    [kvlist] -> m = Map.new(kvlist)
      %{ entity_id: m["entityid"],
        ip: m["ip"],
        name: m["name"],
        steam_id: Integer.to_string(m["steamid"]),
        steam_owner: Integer.to_string(m["steamOwner"])}
  end

  # Disconnection has a stupidly different format to connection...
  define :disconnection_message, "<'Player disconnected: '> keyvallist" do
    [kvlist] -> m = Map.new(kvlist)
      %{ name: String.replace(m["PlayerName"], "'", ""),
         steam_id: String.replace(m["PlayerID"], "'", "")}
  end

  define :keyvallist, "(keyval <','?> <space?>)+" do
    list -> List.flatten(list)
  end

  define :keyval, "key <'='> value"  do
    [key, value] -> {key, value}
  end

  define :key, "(<!'='> .)+" do
    f -> Enum.join(f)
  end

  define :value, "coordinates / timestamp / float / number / ip / string_val"

  define :preamble, "timestamp <space> float <space> loglevel <space>"

  define :coordinates, "<'('> float <','> <space> float <','> <space> float <')'>" do
    [x,y,z] -> {x,y,z}
  end

  define :string_val, "(<!','> .)*" do
    val -> Enum.join(val)
  end

  # This does not properly handle ipv6 since the GeoIP lookup can't deal with v6 yet.
  define :ip, "<'::ffff:'> number <'.'> number <'.'> number <'.'> number" do
    [a,b,c,d] -> {a,b,c,d}
  end

  define :timestamp, "digit+ '-' digit+ '-' digit+ 'T' digit+ ':' digit+ ':' digit+" do
    timestamp -> Enum.join(timestamp)
  end

  define :loglevel, "infolog / errorlog"

  define :infolog, "'INF'" do
    _level -> :info
  end
  define :errorlog, "'ERR'" do
    _level ->  :error
  end

  define :float, "'-'? number '.' number" do
    f ->
      {value, _} = Enum.join(f) |> Float.parse
      value
  end

  define :number, "digit+" do
    digits -> digits |> Enum.join |> String.to_integer
  end

  define :digit, "[0-9]"

  define :space, "[ \\t\\n\\s\\r]*"

  define :quot, "[']"

  define :eol, "[\\r] [\\n]" do
    _ -> :eol
  end
end
