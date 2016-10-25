# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :revenant, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:revenant, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
config :logger, level: :info

config :revenant,
  ecto_repos: [Revenant.Repo],
  worker_timeout: 5000,
  telnet_listen_interval: 500,
  telnet_recv_timeout: 1000,
  player_tracker_interval: 10000,
  inventory_tracker_interval: 30000,
  who_distance: 50,
  login_message_delay: 15000,
  ping_track_count: 5


# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

import_config "#{Mix.env}.exs"
