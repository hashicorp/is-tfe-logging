# is-tfe-logging

Elasticsearch and Kibana demo for consuming and parsing TFE logs. NOTE: This is NOT for production use!

E(lasticsearch)F(luentd)K(ibana) Stack to work with TFE logs
.
## How to Use

```hcl
module "elk" {
  source = "git@github.com:straubt1/tfe-elk.git"

  namespace = local.namespace
  vpc_id    = local.vpc_id
  vpc_cidr  = local.vpc_cidr
  key_pair  = local.ssh_key_name

  subnet_id                   = <subnet>
  associate_public_ip_address = true
  external_cidrs              = <your local IP>

  tags = local.tags
}
```

This module will create an EC2 instance with the proper Security Group.

> Note: Currently there is no authentication or TLS on any of this. Use the external CIDRs to only allow your local machine to be able to access the kibana portal. This is **critical** if you add a public IP to the instance!!

On the new instance, this repo will be cloned, and docker-compose will run.

Once the infrastructure is created, go to the TFE instance.

From TFE, run this to send **all** container logs except the logspout image itself:

```sh
fluentdURL="***.compute.amazonaws.com"
docker run --rm -dt \
  --name="logspout" \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  -e LOGSPOUT="ignore" \
  gliderlabs/logspout \
  syslog+tcp://${fluentdURL}:5140
```


## Kibana Queries

```sh
- [TFE] VCS Webhooks
  - "action:*webhook"
- [TFE] REST Calls
  - "method:*"
  - path
  - status
  - duration
- [TFE] Non-2XX Rest Call
  - "method:* AND NOT status:[200 TO 299]"
- [Audit Log] All Actions
  - "action:*"
  - actions:
    - destroy
    - create
    - update
    - receive_webhook
    - create_webhook
    - queue
- [Audit Log] Queue Run Action
  - "action:queue AND resource:run"
- [Audit Log] Actors
  - "actor:*"
  - "actor_ip:*"
  - remote_ip
- [TFE] Container Messages
  - "ident:*"
  - message
- [TFE] Health Check
  - "path:"/_health_check""
- [TFE] Non-200 Health Check
  - "path:"/_health_check" AND NOT status:200"
- [TFE] Errors
  - "@log_name:"system.user.err""
- [TFE] Run Errors
  - "message:"Job failed""
  - do not add this in cases where its an alternative worker image "AND @module:terraform-build-worker"
- [TFE] Platform Errors
  - "message:error"
- [TFE] All Policy Checks
  - "ident:ptfe_atlas AND policycheckid:*"
  - NOTE: this is only possible with the grok processor
```

### Configure Kibana

> Note: Most/all of this is automated in the user_data, but info is here for understanding of what it takes to get started.

Go to the elastic search indices page, http://<url>:5601/app/kibana#/management/elasticsearch/index_management/

And get the auto created index name, fluentd-*

Go to the console, http://<url>:5601/app/kibana#/dev_tools/console
Run:

```sh
PUT _ingest/pipeline/json_pipeline
{
  "description" : "JSON pipeline",
  "processors" : [
    {
      "script": {
        "lang": "painless",
        "source": """
          if (ctx.message.contains("{") && ctx.message.contains("}")) {
            def first = ctx.message.indexOf('{');
            def last = ctx.message.lastIndexOf('}');
            ctx.json = ctx.message.substring(first, last + 1)
          }
        """,
        "if": "ctx.containsKey('message')",
        "on_failure" : [
        {
          "set" : {
            "field" : "error",
            "value" : "Failed parsing message field while looking for JSON."
          }
        }
        ]
      }
    },
    {
      "json" : {
        "field" : "json",
        "add_to_root": true,
        "if": "ctx.containsKey('json')",
        "on_failure" : [
        {
          "set" : {
            "field" : "error",
            "value" : "Failed to parse json field."
          }
        }
        ]
      }
    }
  ]
}

PUT /fluentd-20200717/_settings
{
    "index" : {
        "default_pipeline" : "json_pipeline"
    }
}
```

If you want to test the pipeline processor:

```sh
POST _ingest/pipeline/json_pipeline/_simulate
{
  "docs": [
    {
      "_source":{
        "logs": "{\"resource\":\"state_version\",\"action\":\"read\",\"resource_id\":\"sv-axTeSEq8rTq2YSMs\",\"organization\":\"hashicorp\",\"actor\":\"api-org-hashicorp\",\"timestamp\":\"2020-07-17T13:56:10Z\",\"actor_ip\":\"52.9.197.235, 10.0.1.63\"}"
      }
    }
  ]
}
```

Create Kibana Index Pattern, http://<url>:5601/app/kibana#/management/kibana/index_patterns

Index Pattern: "fluentd-*"
Time Filter: "@timestamp()"

http://<url>:5601/app/kibana#/discover

Force a TFE run change (queue or discard a plan).

Trigger an update on the Index Pattern.


### Fluentd as SysLog endpoint

https://docs.fluentd.org/input/syslog

## References

- <https://medium.com/@sece.cosmin/docker-logs-with-elastic-stack-elk-filebeat-50e2b20a27c6>
- <https://github.com/cosminseceleanu/tutorials>
- <https://www.docker.elastic.co/>
- <https://www.terraform.io/docs/enterprise/admin/logging.html#application-logs>
- <https://github.com/gliderlabs/logspout#environment-variables>
- <https://hub.docker.com/r/gliderlabs/logspout/>

## TODO

- Add TLS to operate over HTTPS
- Add authentication to kibana

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| associate\_public\_ip\_address | If the ELK instance should have a public IP or not. | `bool` | `false` | no |
| external\_cidrs | List of CIDR ranges to allow traffic ingress into VPC. | `list(string)` | `[]` | no |
| instance\_type | The instance type/size to cretate. | `string` | `"m5.large"` | no |
| key\_pair | AWS SSH key pair name to user for the instance. | `string` | n/a | yes |
| namespace | The name to prefix to resources to keep them unique. | `string` | `"tfe-elk"` | no |
| subnet\_id | The subnet id to create the instance in. | `string` | n/a | yes |
| tags | Tags to apply to every resource | `map` | `{}` | no |
| tfe\_elk\_branch | The branch of this repo to clone on to the instance to run/configure ELK. | `string` | `"main"` | no |
| tfe\_elk\_repo | The repo to clone on to the instance to run/configure ELK (i.e. THIS repo). | `string` | `"https://github.com/hashicorp/is-tfe-logging.git"` | no |
| vpc\_cidr | CIDR block for PTFE AWS VPC. This is needed for the SG network access into the instance. | `string` | n/a | yes |
| vpc\_id | Id of the VPC. This is needed for the SG network access into the instance. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns | DNS of fluentd. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->