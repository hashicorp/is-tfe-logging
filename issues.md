# Highlights/Issues

All things are related to release 202005-2.

## Audit Logs

- Containers that have "[Audit Log]", do we care about 'ptfe_sidekiq'?
  - /ptfe_sidekiq
  - /ptfe_atlas

- Docs say audit log format is `[INFO] [Audit Log]` but found:
  - `2020-07-16 22:11:07 [INFO] [94f11945-f71d-4b27-adf3-f79b243fc57d] [Audit Log]`

## Invalid JSON

Some logs are outputting JSON without commas

- container `ptfe_archivist`
  - `2020/07/20 20:16:56 [INFO] auth: access granted { role.required="admin" token.id="***8a9ed***" token.role="admin" token.source="header" }`

- container `ptfe_sidekiq`
  - `2020-07-24 16:27:06 [INFO] {:nomad_job_id=>"sentinel-worker/dispatch-1595607168-615a08d3", :run_id=>1768, :policy_check_id=>251, :msg=>"Successfully requested kill of sentinel-worker job", :nomad_job=>{:job_id=>"sentinel-worker/dispatch-1595607168-615a08d3", :error=>"nomad job does not exist"}, :action=>:noop}`

- container `ptfe_atlas`
  - `{:state_version=>1421, :controller=>"StateParsingController", :msg=>"State parsed successfully"}`
  - `{:msg=>"Archivist upload completion callback received", :key=>"sentinel/output/8ddcd424/polres-5wVZFmb7J9diNjiY", :object=>"<omitted>", :bytes=>496}`

## Logspout Exclude

Logspout doesn't seem to have an easy mechanism to exclude a set of containers, namely I wanted to not ship replicated logs.

The include functionality is also only based on labels, which not all containers are labeled.
