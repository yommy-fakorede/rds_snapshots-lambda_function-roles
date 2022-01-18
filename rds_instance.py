import boto3
import time

client = boto3.client('rds')
prod_db_name = "mpm-sb-prod"
stage_db_name = "mpm-sb-stage"
snapshot_identifier = prod_db_name + "-snapshot-" + str(time.strftime("%Y-%m-%d-%H-%M"))
snapshot = False
db_delete = False

def lambda_handler(event, context):
    try:
        # print(snapshot_identifier)
        response = client.create_db_snapshot(
            DBSnapshotIdentifier=snapshot_identifier,
            DBInstanceIdentifier=prod_db_name,
            )
        waiter = client.get_waiter('db_snapshot_completed')
        waiter.wait(
            DBInstanceIdentifier=prod_db_name,
            DBSnapshotIdentifier=snapshot_identifier,
        )
        print("Successfully took snapshot of production database. Snapshot name is " + response["DBSnapshot"]["DBSnapshotIdentifier"])
        snapshot = True
    except Exception as e:
        print("An exception occurred while taking production DB snapshot.\n" + str(e))

    if(snapshot):
        try:
            response = client.delete_db_instance(
                DBInstanceIdentifier=stage_db_name,
                SkipFinalSnapshot=True,
                DeleteAutomatedBackups=False
                )
            waiter = client.get_waiter('db_instance_deleted')
            waiter.wait(
                DBInstanceIdentifier=stage_db_name,
            )
            print("Successfully deleted staging DB instance.")
            db_delete = True
        except Exception as e:
            print("An exception occurred while taking deleting staging DB instance.\n" + str(e))

    if(db_delete):
        try:
            response = client.restore_db_instance_from_db_snapshot(
                DBInstanceIdentifier=stage_db_name,
                DBSnapshotIdentifier=snapshot_identifier,
                PubliclyAccessible=False,
                DBSubnetGroupName='mpulse-sandbox',
                )
            print("Creating new staging DB from production snapshot. DB name is " + response["DBInstance"]["DBInstanceIdentifier"])
        except Exception as e:
            print("An exception occurred while creating new staging DB snapshot.\n" + str(e))

# lambda_handler("test", "test")

