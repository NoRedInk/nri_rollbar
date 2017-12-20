defmodule NriRollbarException do
  @moduledoc """
    Wrapper exception to conform with the Rollbax API.
  """
  defexception [:message]
end

defmodule NriRollbar do
  @moduledoc """
    Wrapper around the Rollbax library, for sending messages to Rollbar.
  """
  require Logger
  alias NriRollbarException

  @doc """
    Thin wrapper around `Rollbax.report/4` for communicating with Rollbar. shares
    company conventions for Rollbar message structuring, and namespaces under
    service-specific error for easy searching.
  """
  def report(%{message: message, impact: impact, advisory: advisory, value: value}) do
    Rollbax.report(
      :error,
      %NriRollbarException{message: message},
      System.stacktrace(),
      %{impact: impact, advisory: advisory, value: value}
    )

    # by default, all error logs are sent to rollbar. since we are explicitly
    # sending the message to rollbar, we prevent the double submission below.
    Logger.error(message, rollbar: false)
  end

  @doc """
    Interface for handling request errors captured by `Plug.ErrorHandler`.
  """
  def report_request_error(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    annotated_conn = conn
                     |> Plug.Conn.fetch_cookies()
                     |> Plug.Conn.fetch_query_params()

    conn_data = %{
      "request" => %{
        "cookies" => annotated_conn.req_cookies,
        "url" => "#{annotated_conn.scheme}://#{annotated_conn.host}:#{annotated_conn.port}#{annotated_conn.request_path}",
        "user_ip" => (annotated_conn.remote_ip |> Tuple.to_list() |> Enum.join(".")),
        "headers" => Enum.into(annotated_conn.req_headers, %{}),
        "params" => annotated_conn.params,
        "method" => annotated_conn.method,
      }
    }

    # TODO - extract into configuration
    context = %{
      impact: "Admin pages and reports pages on NoRedInk may experience errors",
      advisory: "This may be caused by failure to access the database or wrong parameters when accessing the API"
    }

    Rollbax.report(kind, reason, stacktrace, context, conn_data)
  end
end
