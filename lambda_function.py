import boto3
import os
from pprint import pprint
import time

logs = boto3.client('logs')
ssm = boto3.client('ssm')

def lambda_handler(event, context):
    extra_args = {}
    log_groups = []
    log_groups_to_export = []
    
    if 'S3_BUCKET' not in os.environ:
        print("Error: S3_BUCKET not defined")
        return
    
    print("--> S3_BUCKET=%s" % os.environ["S3_BUCKET"])
    
    while True:
        response = logs.describe_log_groups(**extra_args)
        log_groups = log_groups + response['logGroups']
        
        if not 'nextToken' in response:
            break
        extra_args['nextToken'] = response['nextToken']
    
    
    for log_group in log_groups:
        log_group_name = log_group['logGroupName']
        log_groups_to_export.append(log_group['logGroupName'])

    
    for log_group_name in log_groups_to_export:
        ssm_parameter_name = ("/log-exporter-last-export/%s" % log_group_name).replace("//", "/")
        try:
            ssm_response = ssm.get_parameter(Name=ssm_parameter_name, WithDecryption=True)
            ssm_value = ssm_response['Parameter']['Value']
            ssm_value = int(ssm_value)
            #delete the old parameter once value is fetched
            ssm_response = ssm.delete_parameter(Name=ssm_parameter_name)
        except ssm.exceptions.ParameterNotFound:
            ssm_value = "0"
        except ValueError:
            print("Error: SSM parameter %s has an invalid value: %s" % (ssm_parameter_name, ssm_value))
            ssm_value = "0"
            continue    
        
        export_to_time = int(round(time.time() * 1000))
        
        print("--> Exporting %s to %s" % (log_group_name, os.environ['S3_BUCKET']))
        
        if export_to_time - int(ssm_value) < (24 * 60 * 60 * 1000):
            # Haven't been 24hrs from the last export of this log group
            print("    Skipped until 24hrs from last export is completed")
            continue
        
        max_retries = 10 
        while max_retries > 0:
            try:
                response = logs.create_export_task(
                    logGroupName=log_group_name,
                    fromTime=0, #exports logs from 1,jan,1970
                    to=export_to_time, #current time
                    destination=os.environ['S3_BUCKET'],
                    destinationPrefix=log_group_name.strip("/")
                )    
                print("    Task created: %s" % response['taskId'])
                ssm_response = ssm.put_parameter( #method of ssm client to store the current time as last time 
                    Name=ssm_parameter_name,
                    Type="SecureString",
                    Value=str(export_to_time),
                    Overwrite=True)

                break
                
            except logs.exceptions.LimitExceededException:
                max_retries = max_retries - 1
                print("    Need to wait until all tasks are finished (LimitExceededException). Continuing %s additional times" % (max_retries))
                time.sleep(5) #wait to complete exporting multiple logs before continuing to do next ExportTask
                continue
            
            except Exception as e:
                print("    Error exporting %s: %s" % (log_group_name, getattr(e, 'message', repr(e))))
                break
