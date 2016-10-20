defmodule Revenant.Repo.Migrations.CreateTriggersOnChat do
  use Ecto.Migration

  def up do
    execute """
        CREATE FUNCTION delete_old_chats() RETURNS trigger
          LANGUAGE plpgsql AS
          $$
            BEGIN
              DELETE FROM chats WHERE inserted_at < NOW() AT TIME ZONE 'UTC' - INTERVAL '7 days';
              RETURN NULL;
            END;
          $$;
      """

    execute """
      CREATE TRIGGER trigger_delete_old_chats
        AFTER INSERT ON chats
        EXECUTE PROCEDURE delete_old_chats();
     """
  end

  def down do
    execute "DROP TRIGGER trigger_delete_old_chats ON chats;"
    execute "DROP FUNCTION IF EXISTS delete_old_chats();"
  end
end
