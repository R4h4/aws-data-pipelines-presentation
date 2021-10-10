import json
import uuid
import string
import random
from time import sleep

from tqdm import tqdm
import boto3

session = boto3.session.Session(profile_name='AudienceServAWS')
client = session.client('kinesis', region_name='eu-west-1')


def random_char(char_num):
    return ''.join(random.choice(string.ascii_letters) for _ in range(char_num))


if __name__ == '__main__':
    # Create 3 campaign ids
    campaign_ids = [str(uuid.uuid4()) for _ in range(3)]
    for _ in tqdm(range(60)):
        client.put_records(
            Records=[{
                'Data': json.dumps({
                    'email': random_char(7) + '@gmail.com',
                    'campaign_id': random.choice(campaign_ids)
                }),
                'PartitionKey': str(uuid.uuid4())
            } for _ in range(random.randint(50, 500))],
            StreamName='moon-pipelines-dev-transformed'
        )
        sleep(2)


