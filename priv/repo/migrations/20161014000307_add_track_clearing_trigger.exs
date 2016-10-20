defmodule Revenant.Repo.Migrations.AddTrackClearingTrigger do
  use Ecto.Migration

  def up do
    execute """
        CREATE FUNCTION delete_old_tracks() RETURNS trigger
          LANGUAGE plpgsql AS
          $$
            BEGIN
              DELETE FROM tracks WHERE inserted_at < NOW() AT TIME ZONE 'UTC' - INTERVAL '1 day';
              RETURN NULL;
            END;
          $$;
      """

    execute """
      CREATE TRIGGER trigger_delete_old_tracks
        AFTER INSERT ON tracks
        EXECUTE PROCEDURE delete_old_tracks();
     """
  end

  def down do
    execute "DROP TRIGGER trigger_delete_old_tracks ON tracks;"
    execute "DROP FUNCTION IF EXISTS delete_old_tracks();"
  end
end
