# Grok Patterns

List of patterns used to parse incoming TFE logs per container.

## ptfe_atlas

Primary log output

### Audit Logs

No Grok Needed, instead just bubble up nested JSON.

Condition: 'message' contains "[Audit Log]" AND 'action' is set

Example:

```
2020-07-28 16:55:13 [INFO] [b172fdac-c4c6-4498-886c-c6fcb39d632a] [Audit Log] {"resource":"state_version","action":"read","resource_id":"sv-c3RZoGnM7xMcuKjP","organization":"enough-mosquito","actor":"api-org-enough-mosquito","timestamp":"2020-07-28T16:55:13Z","actor_ip":"52.9.197.235, 10.0.1.63"}
```

### HTTP Requests

No Grok Needed, instead just bubble up nested JSON.

Condition: `method`, `path`, and `status` are set

Example:

```
2020-07-28 17:17:17 [INFO] [e4e36778-3402-4a89-9790-727baf12cedb] {"method":"GET","path":"/api/v2/runs/run-UYHifEiFWdoAfEqr/run-events","format":"jsonapi","status":200,"duration":108.9,"view":15.71,"db":40.07,"uuid":"e4e36778-3402-4a89-9790-727baf12cedb","remote_ip":"175.13.170.101, 10.0.0.32","request_id":"e4e36778-3402-4a89-9790-727baf12cedb","user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:78.0) Gecko/20100101 Firefox/78.0","user":"tstraub"}
```

### Archivist Upload

JSON will fail due to malformed JSON string.

Condition: 'message' contains "Archivist upload completion callback received"

Example:

```
{:msg=>"Archivist upload completion callback received", :key=>"sentinel/output/8ddcd424/polres-5wVZFmb7J9diNjiY", :object=>"dmF1bHQ6djE6WGUyVytsTkhUbTc0UVBKdnhNRG5NR2s1aUduTC9QRnA5Z3dZWDNYUVJreHQrOUVsNjFERFI0cGgvMG5vVXdRaEJkbmZIUmQyQzN5L2FadTY5Y1Fpak1EUkliR2dvenJXUFQ1YWxLRlo5R29HYkVXRFIvbnk1Tk5Ba0Y2ZGVKN0ptMURDSUJodjlJMEkvWk5rRlVWYXBUMTFoN0VReXlkVHZudFVHN3h4ZjdOZ00xaDdjVkU5SEgwNnc1M0hZeTBZYzVqOFZ1YnNxZVZkK05MQmZUNUo2dHhWM2liaXk5UzFvZTVxWUlGVzlNNG5mNHk0NkFFNmdUSEVzZVJUMStDOHQ3T0h3ZkJXUlFlc3hFOFZHVUJxenU3QWxvOE9nK1prNDA4MXZTejViUk1TWEY5OE9QckRCM2J3N1E9PQ", :bytes=>496}
```

### StateParsingController

JSON will fail due to malformed JSON string.

Condition: 'message' contains "StateParsingController"

Example:

```
{:state_version=>1421, :controller=>"StateParsingController", :msg=>"State parsed successfully"}
```

### Sentinel Policy Check

Condition: 'message' should contain "Finished policy check"

Pattern Definitions:

```
"TFEID": "%{WORD}-%{WORD}"
```

Pattern:

```
%{DATESTAMP} \\[%{WORD:logtype}\\] \\[%{UUID:refid}\\] Finished policy check %{TFEID:policycheckid} on run %{TFEID:runid}. Result: %{WORD:result}, Passed: %{NUMBER:passed}, Total failed: %{NUMBER:totalfailed}, Hard failed: %{NUMBER:hardfailed}, Soft failed: %{NUMBER:softfailed}, Advisory failed: %{NUMBER:advisoryfailed}, Duration ms: %{BASE16FLOAT:duration}
```

Example:

```
2020-07-28 16:51:15 [INFO] [364de90d-da0f-4b85-88d7-43acf01e51a6] Finished policy check polchk-4GcWtwKGkdizQXbD on run run-1TACscLJiRCDP4Wt. Result: true, Passed: 1, Total failed: 0, Hard failed: 0, Soft failed: 0, Advisory failed: 0, Duration ms: 0
```

### Rendered ActiveModel

Unneeded log

Condition: 'message' should contain "Rendered ActiveModel"

Example:

```
2020-07-28 17:09:25 [INFO] [87138862-59a6-49bb-a8cd-b12e5e6a023c] [active_model_serializers] Rendered ActiveModel::Serializer::CollectionSerializer with ActiveModelSerializers::Adapter::JsonApi (22.01ms)
```

### Ruby Analytics

Unneeded logs

Condition: 'message' should contain "[analytics-ruby]"

Examples:

```
2020-07-28 16:55:53 [DEBUG] [analytics-ruby] Sending request for 1 items
```
```
2020-07-28 16:55:53 [DEBUG] [analytics-ruby] stubbed request to /v1/import: write key = segment-dev, batch = JSON.generate(#<Segment::Analytics::MessageBatch:0x000056405924dde0>)
```
```
2020-07-28 16:55:53 [DEBUG] [analytics-ruby] Response status code: 200
```