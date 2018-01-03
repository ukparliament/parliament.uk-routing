import boto3

ecs = boto3.client('ecs')
ec2 = boto3.client('ec2')

def get_paginated_results(func, key, **kwargs):
    """
    Many boto3 methods return only a limited number of results at once,
    with pagination information. This function handles the pagination to
    retrieve the entire result set.

    @param func
        The function to call to get the data.
    @param key
        The key in the result set returned from the function containing the data
        that we want
    @param kwargs
        The arguments to pass to each call to func.
    @returns
        An iterable containing the results of the consecutive calls to func.
    """
    next_token = ''
    more = True
    while more:
        result = func(**kwargs, nextToken=next_token)
        things = result[key]
        next_token = result.get('nextToken', None)
        more = next_token != None
        for thing in things:
            yield thing


def bundle(ids, block_size):
    """
    Given an iterable, bundles it into lists, each block_size long.

    @param ids
        The things to bundle
    @param block_size
        The maximum size of each block
    @returns
        An iterable of blocks, each containing up to block_size things.
    """

    block = []

    for id in ids:
        block.append(id)
        if len(block) == block_size:
            yield block
            block = []
    if len(block):
        yield block


def bundled_map(ids, block_size, func):
    """
    A map function where the mapping function is applied to blocks of items
    rather than to individual things.

    @param ids
        The things to be mapped.
    @param block_size
        The number of things to be mapped at a time
    @param func
        A mapping function that maps a block of block_size things at a time.
    """
    blocks = bundle(ids, block_size)
    for block in blocks:
        things = func(block)
        for thing in things:
            yield thing


# ====== Get services and tasks ====== #

def get_services(cluster):
    """
    Gets a list of all defined ECS services.
    """
    service_ids = get_paginated_results(ecs.list_services, 'serviceArns', cluster=cluster)
    services = bundled_map(
        service_ids, 10,
        lambda x: ecs.describe_services(cluster=cluster, services=x)['services']
    )
    return services

def get_tasks(cluster):
    """
    Gets a list of all running tasks
    """
    task_ids = get_paginated_results(ecs.list_tasks, 'taskArns', cluster=cluster)
    tasks = bundled_map(
        task_ids, 100,
        lambda x: ecs.describe_tasks(cluster=cluster, tasks=x)['tasks']
    )
    return tasks

def list_tasks(cluster):
    tasks = list(get_tasks(cluster))

    # Get the container instances
    container_instance_arns = {
        task['containerInstanceArn'] for task in tasks
    }
    container_instances = ecs.describe_container_instances(
        cluster=cluster,
        containerInstances=tuple(container_instance_arns)
    )['containerInstances']

    # Map container instance ARN to EC2 instance ID
    container_instances = {
        ci['containerInstanceArn']: ci['ec2InstanceId']
        for ci in container_instances
    }

    # Describe the EC2 instances
    ec2_instance_ids = set(container_instances.values())
    ec2_instances = [
        instance
        for reservation in bundled_map(
            ec2_instance_ids, 1000,
            lambda x: ec2.describe_instances(
                InstanceIds=tuple(ec2_instance_ids)
            )['Reservations']
        )
        for instance in reservation['Instances']
    ]

    # Map instance IDs to instance data
    ec2_instances = {
        instance['InstanceId']: instance
        for instance in ec2_instances
    }

    def get_ec2_instance_by_container_instance_arn(arn):
        ec2_instance_id = container_instances[arn]
        return ec2_instances[ec2_instance_id]

    def get_service_name(group_name):
        name = group_name.split(':')[-1]
        if name.startswith('parliamentuk'):
            name = name[12:]
        return name

    return [
        {
            'group': task['group'],
            'service': get_service_name(task['group']),
            'ip': get_ec2_instance_by_container_instance_arn(task['containerInstanceArn'])['PrivateIpAddress'],
            'ports': tuple((
                networkBinding['hostPort']
                for container in task['containers']
                for networkBinding in container['networkBindings']
            ))
        }
        for task in tasks
    ]
