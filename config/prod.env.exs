use Mix.Config

# please rewirte your config
config :gitlab_webhook, :stalker,
  [
    [
      project_path: "",
      stalker_branch: "",
      victim_branch: "",
      slack_notice: [
        icon: "",
        mention: "",
        channel: ""
      ]
    ]
  ]

config :gitlab_webhook, :external,
  graphql_api_endpoint: "",
  rest_api_endpoint: "",
  access_token: "",
  slack_notice_endpoint: ""
