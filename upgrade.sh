#!/bin/bash

set -o errexit
cd `dirname $0`
eval `./admin/ShowDBDefs`

if [ "$DB_SCHEMA_SEQUENCE" != "14" ]
then
    echo `date` : Error: Schema sequence must be 14 when you run this script
    exit -1
fi

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : Export pending db changes
    ./admin/RunExport

    echo `date` : Drop replication triggers
    ./admin/psql READWRITE < ./admin/sql/DropReplicationTriggers.sql
fi

echo `date` : 20120410-multiple-iswcs-per-work.sql
./admin/psql < admin/sql/updates/20120410-multiple-iswcs-per-work.sql

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : Create replication triggers
    ./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : 20120410-multiple-iswcs-per-work.sql
    ./admin/psql < admin/sql/updates/20120410-multiple-iswcs-per-work-constraints.sql
fi

DB_SCHEMA_SEQUENCE=15
echo `date` : Going to schema sequence $DB_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $DB_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

echo `date` : Done
echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $DB_SCHEMA_SEQUENCE !

# eof
