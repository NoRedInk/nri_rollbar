# NriRollbar

A simple wrapper of [Rollbax](https://github.com/elixir-addicts/rollbax) with some additional helper methods.

## Required Configuration

To allow connecting to Rollbar you need to add a configuration section in `config/<env>.exs` to set the environment name and rollbar tokens as follows:

```elixir
config :rollbax,
  environment: <env>,
  access_token: <inside the secrets file>
```

To ensure rollbar messages have additional information when capturing Plug errors you should add a configuration block to `config/config.exs`:

```elixir
config :nri_rollbar,
  plug_default_impact: <Describe the impact of this service web endpoints failing>,
  plug_default_advisory: <Give hints to how to resolve, point to playbook>
```

## Installation

The package can be installed
by adding `nri_rollbar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:nri_rollbar, github: "NoRedInk/nri_rollbar", tag: "v0.1.0"}]
end
```
