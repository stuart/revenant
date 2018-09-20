defmodule Revenant.Worker.Shop do
  use Revenant.Worker.Simple

  def handle_command(%State{user: user, socket: socket, args: shop_args}) do
    Revenant.ServerSocket.pm socket, user, handle_shop(shop_args)
  end

  def handle_shop [] do
    "[ccffcc]Shop is not implemented yet..."
  end

  def handle_shop _ do
    "[ccffcc]Unknown shop command."
  end
end
