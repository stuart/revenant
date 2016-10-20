defmodule Revenant.Worker.Help do
  use Revenant.Worker.Simple

  def handle_command(%State{user: user, socket: socket, args: help_args}) do
    Revenant.ServerSocket.pm socket, user, help_message(help_args)
  end

  defp help_message(["/day"]) do
    "[ccccff]/day : [cccccc]Shows how many days and hours to the next horde."
  end

  defp help_message(["/sethome"]) do
    "[ccccff]/sethome : [cccccc]Sets your home teleport location to your current position."
  end

  defp help_message(["/home"]) do
    "[ccccff]/home : [cccccc]teleports you to the position that you previously set with /sethome."
  end

  defp help_message(["/who"]) do
    "[ccccff]/who : [cccccc]shows names of players that have been within 50 metres of your current position within the last 24 hours."
  end

  defp help_message(["/zgate"]) do
    """
      [ccccff]/zgate : [cccccc]zGates are locations that you can set to teleport to.
      [ccccff]/zgate create <name> : [cccccc]creates a zGate with that name.
      [ccccff]/zgate delete <name> : [cccccc]removes a zGate.
      [ccccff]/zgate visit <name>  : [cccccc]teleports you to a zGate.
      [ccccff]/zgate toggle <name> : [cccccc]make a zGate public or private.
      [ccccff]/zgate list : [cccccc]lists all your zGates.
      [ccccff]/zgate list public : [cccccc]lists all public zGates.
    """
  end
  defp help_message _ do
    """
      [ccffcc]Revenant Help

      [cccccc]For help on specific commands use: [ccccff]/help <command>

      [cccccc]Commands available are:
        [ccccff]/help : [cccccc]show this message.
        [ccccff]/day  : [cccccc]show how many days and hours to the next horde.
        [ccccff]/sethome : [cccccc]set a home location.
        [ccccff]/home : [cccccc]teleport to your home location.
        [ccccff]/who : [cccccc]see who has been around you current position.
    """
  end
end
