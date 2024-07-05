alias KsWeb.Posts
alias KsWeb.Posts.Post

alias KsWeb.Templates
alias KsWeb.Sidenote

import KsWeb.Sluggify, only: [slug!: 1]

KsWeb.Config.put_toml_config("config.toml")
