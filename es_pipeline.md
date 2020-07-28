# Pipeline


## Drop Replicated Logs

This will find any container that is associated with replicated specific containers and drop it so that it is not indexed.

> Note: It is debatable if we should throw out all replicated logs. Done in this module to keep things focused on TFE.

```
{
  "drop": {
    "if" : "ctx.ident.contains(\"replicated\") || ctx.ident.contains(\"retraced\")"
  }
}
```

## Look for JSON

This will do a rough check of the `message` field to see if there is JSON present, if there is it will write just the JSON to a `json` field. If there is no JSON, nothing will happen, all errors are logged to the `jsonerror` field.

> Note: Literally only checks for opening and closing braces, and copies that string.

```
{
  "script": {
    "lang": "painless",
    "source": "\n          if (ctx.message.contains(\"{\") && ctx.message.contains(\"}\")) {\n            def first = ctx.message.indexOf('{');\n            def last = ctx.message.lastIndexOf('}');\n            ctx.json = ctx.message.substring(first, last + 1)\n          }\n        ",
    "if": "ctx.containsKey('message')",
    "on_failure": [
      {
        "set": {
          "field": "jsonerror",
          "value": "Failed parsing message field while looking for JSON."
        }
      }
    ]
  }
}
```

## JSON Parse

If the `json` field is present from the previous processor, parse it and bubble up all fields to the root of the message. If there is parse fails, nothing will happen, all errors are logged to the `jsonerror` field.

```
{
  "json": {
    "field": "json",
    "add_to_root": true,
    "if": "ctx.containsKey('json')",
    "on_failure": [
      {
        "set": {
          "field": "jsonerror",
          "value": "Failed to parse json field."
        }
      }
    ]
  }
}
```

## Grok for Sentinel

Look for sentinel pattern and create fields.

```
{
  "grok": {
    "field": "message",
    "if": "ctx.message.contains(\"Finished policy check\")",
    "on_failure": [
      {
        "set": {
          "field": "grokerror",
          "value": "{{ _ingest.on_failure_message }}"
        }
      }
    ],
    "pattern_definitions": {
      "TFEID": "%{WORD}-%{WORD}"
    },
    "patterns": [
      "%{DATESTAMP} \\[%{WORD:logtype}\\] \\[%{UUID:refid}\\] Finished policy check %{TFEID:policycheckid} on run %{TFEID:runid}. Result: %{WORD:result}, Passed: %{NUMBER:passed}, Total failed: %{NUMBER:totalfailed}, Hard failed: %{NUMBER:hardfailed}, Soft failed: %{NUMBER:softfailed}, Advisory failed: %{NUMBER:advisoryfailed}, Duration ms: %{BASE16FLOAT:duration}"
    ]
  }
}
```

## Full Pipeline

```
[
  {
    "drop": {
      "if" : "ctx.ident.contains(\"replicated\") || ctx.ident.contains(\"retraced\")"
    }
  },
  {
    "script": {
      "lang": "painless",
      "source": "\n          if (ctx.message.contains(\"{\") && ctx.message.contains(\"}\")) {\n            def first = ctx.message.indexOf('{');\n            def last = ctx.message.lastIndexOf('}');\n            ctx.json = ctx.message.substring(first, last + 1)\n          }\n        ",
      "if": "ctx.containsKey('message')",
      "on_failure": [
        {
          "set": {
            "field": "jsonerror",
            "value": "Failed parsing message field while looking for JSON."
          }
        }
      ]
    }
  },
  {
    "json": {
      "field": "json",
      "add_to_root": true,
      "if": "ctx.containsKey('json')",
      "on_failure": [
        {
          "set": {
            "field": "jsonerror",
            "value": "Failed to parse json field."
          }
        }
      ]
    }
  },
  {
    "grok": {
      "field": "message",
      "if": "ctx.message.contains(\"Finished policy check\")",
      "on_failure": [
        {
          "set": {
            "field": "grokerror",
            "value": "{{ _ingest.on_failure_message }}"
          }
        }
      ],
      "pattern_definitions": {
        "TFEID": "%{WORD}-%{WORD}"
      },
      "patterns": [
        "%{DATESTAMP} \\[%{WORD:logtype}\\] \\[%{UUID:refid}\\] Finished policy check %{TFEID:policycheckid} on run %{TFEID:runid}. Result: %{WORD:result}, Passed: %{NUMBER:passed}, Total failed: %{NUMBER:totalfailed}, Hard failed: %{NUMBER:hardfailed}, Soft failed: %{NUMBER:softfailed}, Advisory failed: %{NUMBER:advisoryfailed}, Duration ms: %{BASE16FLOAT:duration}"
      ]
    }
  }
]
```