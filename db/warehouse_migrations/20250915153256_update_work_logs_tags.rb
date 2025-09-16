# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Sequel.migration do
  up do
    # Convert work_logs.tags from text[] to jsonb
    run <<~SQL
      ALTER TABLE work_logs
      ALTER COLUMN tags TYPE jsonb
      USING CASE
        WHEN tags IS NULL THEN NULL
        ELSE to_jsonb(tags)
      END;
    SQL

    # Convert work_logs_history.tags from text[] to jsonb
    run <<~SQL
      ALTER TABLE work_logs_history
      ALTER COLUMN tags TYPE jsonb
      USING CASE
        WHEN tags IS NULL THEN NULL
        ELSE to_jsonb(tags)
      END;
    SQL
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
