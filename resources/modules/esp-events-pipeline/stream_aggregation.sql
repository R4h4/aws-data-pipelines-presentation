CREATE OR REPLACE STREAM "INCOMING_STREAM" (
    "email" VARCHAR(80),
    "campaign_id" VARCHAR(80));

CREATE OR REPLACE PUMP "INCOMING_STREAM_PUMP" AS
    INSERT INTO "INCOMING_STREAM" ("email", "campaign_id")
        SELECT STREAM
            "email",
            "campaign_id"
        FROM "prefix_001";

CREATE OR REPLACE PUMP "INCOMING_STREAM" AS
    INSERT INTO "OUTPUT_S3" ("campaign", "no_sent")
    SELECT STREAM campaign_id, count(distinct email)
    FROM stream_name
    GROUP BY FLOOR((\"prefix_001\".ROWTIME - TIMESTAMP '1970-01-01 00:00:00') SECOND / 10 TO SECOND);
    FROM "INCOMING_STREAM"