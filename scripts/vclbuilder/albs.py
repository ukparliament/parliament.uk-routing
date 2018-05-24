import boto3
import socket

elb2 = boto3.client('elbv2')

def tags_as_dict(tags):
    return { tag['Key']: tag['Value'] for tag in tags }

def resources_with_tags_as_dict(resources):
    return {
        res['ResourceArn']: tags_as_dict(res['Tags'])
        for res in resources
    }

def resolve(hostname):
    return socket.gethostbyname_ex(hostname)[2]

def list_tasks(*args, **kwargs):
    lbdata = elb2.describe_load_balancers()
    load_balancers = lbdata['LoadBalancers']
    load_balancers_by_arn = {
        lb['LoadBalancerArn']: lb
        for lb in load_balancers
    }
    arns = list(load_balancers_by_arn)
    resource_tags = elb2.describe_tags(ResourceArns = arns)['TagDescriptions']
    resource_tags = resources_with_tags_as_dict(resource_tags)
    backends = [
        {
            'service': resource_tags[arn]['varnish_backend'],
            'ip': ip,
            'ports': [ 80, ]
        }
        for arn in resource_tags
        for ip in resolve(load_balancers_by_arn[arn]['DNSName'])
        if 'varnish_backend' in resource_tags[arn]
    ]
    return backends

