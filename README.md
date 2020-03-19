# ebmeds-docker
Create a minimal installation of EBMEDS using Docker Swarm in a one-node cluster.

## Quick start

```
# As a non-root user
git clone https://github.com/ebmeds/ebmeds-docker.git
cd ebmeds-docker
chmod -R 755 .

# You need the proper credentials here
DOCKER_LOGIN=duodecim+example DOCKER_PASSWORD=somePassword sh start.sh
```
## Detailed instructions
Please see the installation instructions at [](https://ebmeds.github.io/docs/installation/)

## Note
For a proper scaling EBMEDS installation, please use the Kubernetes deployment instructions at: https://github.com/ebmeds/ebmeds-kubernetes

# EBMEDS Docker Swarm

The services required to run the EBMEDS is described in the Docker compose file and can be deployed by Docker swarm. There are few things to take into account in order to run the EBMEDS docker through Docker swarm.

This guide assumed that the user has a minimum required version of Docker installed. The Docker compose file format version is `3.3` which needs the Docker Engine version `17.06.0` or higher to deploy. To check the Docker engine version, run:

    $ docker -v

Make sure you are included to the docker user group. Run:

     $ groups

This inputs a list that should include "docker". If you are not included, ask your sysadmin to add you to the group. If you were recently added, a relogin should do the trick. If you have root priviledges, you can add yourself with:

    $ sudo usermod -a -G docker $USER

Next thing to do is to increase the virtual memory address space to the recommended size. By default, the operating system limits on a `mmapfs` counts are likely to be too low, which may result out of memory exception in the Elasticsearch. To increase the limits, run the following command as root (in macOS you must `screen` into the Docker virtual machine in order to set this value):

    $ sudo sysctl -w vm.max_map_count=262144

This set the virtual memory address space value permanently and update the setting in `/etc/sysctl.conf`. To verify after rebooting, run:

    $ sysctl vm.max_map_count

Now, it's time to deploy the EBMEDS by Docker swarm for the first time if you have not yet done so. This step required you to log into the Quay Docker registry service provider where the built EBMEDS images are stored. To deploy the EBMEDS Docker, run:

    # Assuming that you are in the ebmeds-docker project root.
    # To deploy the latest development version, run:
    $ ./start.sh dev

    # To run the production version, run:
    $ ./start.sh

    # To run a specific version of EBMEDS build, e.g. version 2.3.10, run:
    $ ./start.sh 2.3.10

In some Linux distro, the Docker swarm has an issue with the created EBMEDS Docker volumes. This can be easily checked by examining the Logstash logs followingly:

    # To examine the Logstash logs
    $ docker service logs -f ebmeds_logstash

If the Logstash runner print out the following fatal error:

    An unexpected error occurred! {:error=>#<ArgumentError: Path "/usr/share/logstash/data/queue" must be a writable directory. It is not writable.>

Then, it means the deployed EBMEDS does not have right to write on created volumes that its services are mapped to. To fix this, check first where the volume is created followingly:

    $ docker volume inspect --format '{{ .Mountpoint }}' ebmeds_ebmeds-logstash-queue

This command reveals the Logstash volume path e.g.:

    /var/lib/docker/volumes/ebmeds_ebmeds-logstash-queue/_data

Assuming that the path, as mentioned earlier, is our Logstash volume path. Navigate to the `/var/lib/docker/volumes` and run the following command (in macOS, you must first `screen` into the Docker virtual machine, check Docker properties for its location):

    # Make sure you are in the right directory
    $ pwd
    /var/lib/docker/volumes
    # Gives read, write and execute rights to the EBMEDS volumes
    $ sudo chmod -R a+rwx ebmeds_ebmeds*

This gives recursively read, write, execute rights to the owner, group and other to all EBMEDS volumes. This concluded the deployment of the EBMEDS Docker swarm.

It's also worthy to mention that EBMEDS services, e.g. `api-gateway` and `clinical-datastore`, environment variables can be overridden in `config.env` configuration which resides in the project root. Some of the environment variables are global and shared between the EBMEDS Docker services. Such environment variables are e.g. `ELASTIC_APM_ACTIVE` and `EBMEDS_LOG_LEVEL`. Overriding the shared environment variable affect all the services that are using the shared variables.

## Index Lifecycle Management
This operation was carried out in Elastic stack version 7.6.0 – current release at the time.

EBMEDS sends request payloads, triggered reminders and logs data into specific Elasticsearch indices. These indices are:
- ebmeds-request-%{YYYY.MM}
- ebmeds-reminders-%{YYYY.MM}
- ebmeds-logs-%{YYYY.MM}

The year and month are dynamically formed to the index name, so for example, `ebmeds-request-2020.03` is one possible name and so on. To control these indices in `testing` and `staging` environments, we need to apply Elasticsearch index lifecycle manager, which set the rotate rules for every index.

In the Elasticsearch and for time series indices, the index lifecycle has four stages, and they are:
- Hot: the index is actively being updated and queried.
- Warm: the index is no longer being updated, but is still being queried.
- Cold: the index is no longer being updated and is seldom queried. The information still needs to be searchable, but it is okay if those queries are slower.
- Delete: the index is no longer needed and can safely be deleted.

#### Use in testing environment
For the `testing` environment, we get along just with three phases – hot, warm and delete. All the EBMEDS indices are time series. A new entry to the index enters the `hot` stage. After 30 days it will be moved to the `warm` stage and eventually deleted when the data age reached 90 days. Long story short: data that reside in the index longer than 90 days will be deleted.

The index lifecycle management policy needs to be first created into the Elasticsearch before it can be used in the Logstash else an exception is raised. The `ebmeds-policy` can be added into the Elasticsearch followingly:

```bash
curl -X PUT "http://localhost:9200/_ilm/policy/ebmeds-index-policy?pretty" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
      "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_age": "30d"
          },
          "set_priority": {
            "priority": 100
          }
        }
      },
      "warm": {
        "min_age": "0ms",
        "actions": {
          "allocate": {
            "number_of_replicas": 1,
            "include": {},
            "exclude": {},
            "require": {}
          },
          "forcemerge": {
            "max_num_segments": 1
          },
          "set_priority": {
            "priority": 50
          }
        }
      },
      "delete": {
        "min_age": "60d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
'
```

#### Advice for staging and production environment
This index lifecycle policy cannot be used in the `staging` and `production` without modification. The snapshot lifecycle must be configured for the `staging` and `production` environments before we can proceed any further. Make sure that the snapshot lifecycle is working correctly before proceeding. 

Also, make sure that everything is tested in `staging` environment and verified that they work correctly before applying index and snapshot lifecycle to the `production`.

Setting up the snapshot repository is required. Here is a simple skeleton snapshot policy of how to take snapshot daily at midnight.

```json
{
  "schedule": "0 0 * * * ?",
  "name": "ebmeds-snapshot-{now/d}",
  "repository": "<remember to configure repository>",
  "config": {
    "indices": ["*"]
  }
}
```
For more information about snapshot, please consult the links below.  Let say we name this snapshot lifecycle as `ebmeds-snapshot-policy`.

When the snapshot policy is created and running on the indices, we can proceed to set lifecycle policy for the EBMEDS indices. Following is a recommended policy to use with the EBMEDS, but further modification is required depending on the regulations.

```bash
curl -X PUT "http://localhost:9200/_ilm/policy/ebmeds-index-policy?pretty" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
      "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_age": "30d"
          },
          "set_priority": {
            "priority": 100
          }
        }
      },
      "warm": {
        "min_age": "0ms",
        "actions": {
          "allocate": {
            "number_of_replicas": 1,
            "include": {},
            "exclude": {},
            "require": {}
          },
          "forcemerge": {
            "max_num_segments": 1
          },
          "set_priority": {
            "priority": 50
          }
        }
      },
      "delete": {
        "min_age": "150d",
        "actions": {
	  "wait_for_snapshot" : {
            "policy": "ebmeds-snapshot-policy"
          }
          "delete": {}
        }
      }
    }
  }
}
'
```
We now set the `delete` stage to wait for the snapshot to be complete before we can proceed with deletion.

#### Further readings:
- [Manage the index lifecycle](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/index-lifecycle-management.html)
- [Snapshot and restore](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/snapshot-restore.html)
- [Manage the snapshot lifecycle](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/snapshot-lifecycle-management.html)
