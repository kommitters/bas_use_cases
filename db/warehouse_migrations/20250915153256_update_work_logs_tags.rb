# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Sequel.migration do
  up do
    # work_logs
    alter_table(:work_logs) do
      add_column :tags_jsonb, :jsonb
    end

    run <<~SQL
      UPDATE work_logs
      SET tags_jsonb = CASE
        WHEN tags IS NULL THEN NULL
        ELSE (
          SELECT jsonb_agg(jsonb_build_object('id', e, 'name', 'UNKNOWN'))
          FROM unnest(tags) AS e
        )
      END;
    SQL

    alter_table(:work_logs) do
      drop_column :tags
      add_column :tags, :jsonb
    end

    run <<~SQL
      UPDATE work_logs SET tags = tags_jsonb;
    SQL

    alter_table(:work_logs) do
      drop_column :tags_jsonb
    end

    # work_logs_history
    alter_table(:work_logs_history) do
      add_column :tags_jsonb, :jsonb
    end

    run <<~SQL
      UPDATE work_logs_history
      SET tags_jsonb = CASE
        WHEN tags IS NULL THEN NULL
        ELSE (
          SELECT jsonb_agg(jsonb_build_object('id', e, 'name', 'UNKNOWN'))
          FROM unnest(tags) AS e
        )
      END;
    SQL

    alter_table(:work_logs_history) do
      drop_column :tags
      add_column :tags, :jsonb
    end

    run <<~SQL
      UPDATE work_logs_history SET tags = tags_jsonb;
    SQL

    alter_table(:work_logs_history) do
      drop_column :tags_jsonb
    end
  end

  down do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.jsonb_tags_to_text_array(_tags jsonb)
      RETURNS text[]
      LANGUAGE SQL
      IMMUTABLE
      AS $$
        SELECT CASE
          WHEN _tags IS NULL THEN NULL
          ELSE (
            SELECT array_agg(COALESCE(elem->>'id', trim(both '"' from elem::text)))
            FROM jsonb_array_elements(_tags) AS elem
          )
        END
      $$;
    SQL

    # Convert work_logs.tags from jsonb back to text[] using helper function
    run <<~SQL
      ALTER TABLE work_logs
      ALTER COLUMN tags TYPE text[]
      USING public.jsonb_tags_to_text_array(tags);
    SQL

    # Convert work_logs_history.tags from jsonb back to text[] using helper function
    run <<~SQL
      ALTER TABLE work_logs_history
      ALTER COLUMN tags TYPE text[]
      USING public.jsonb_tags_to_text_array(tags);
    SQL

    # Drop helper function
    run <<~SQL
      DROP FUNCTION IF EXISTS public.jsonb_tags_to_text_array(jsonb);
    SQL
  end
end
# rubocop:enable Metrics/BlockLength
