return {
    postgres = {
      up = [[
        DO $$
        BEGIN
          ALTER TABLE IF EXISTS ONLY mbbasicauth_credentials ADD tags TEXT[];
        EXCEPTION WHEN DUPLICATE_COLUMN THEN
          -- Do nothing, accept existing state
        END$$;
        DO $$
        BEGIN
          CREATE INDEX IF NOT EXISTS mbbasicauth_tags_idex_tags_idx ON mbbasicauth_credentials USING GIN(tags);
        EXCEPTION WHEN UNDEFINED_COLUMN THEN
          -- Do nothing, accept existing state
        END$$;
        DROP TRIGGER IF EXISTS mbbasicauth_sync_tags_trigger ON mbbasicauth_credentials;
        DO $$
        BEGIN
          CREATE TRIGGER mbbasicauth_sync_tags_trigger
          AFTER INSERT OR UPDATE OF tags OR DELETE ON mbbasicauth_credentials
          FOR EACH ROW
          EXECUTE PROCEDURE sync_tags();
        EXCEPTION WHEN UNDEFINED_COLUMN OR UNDEFINED_TABLE THEN
          -- Do nothing, accept existing state
        END$$;
      ]],
    },
    cassandra = {
      up = [[
        ALTER TABLE mbbasicauth_credentials ADD tags set<text>;
      ]],
    }
  }