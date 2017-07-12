defmodule VK.Wrapper do
  use HTTPoison.Base

  @endpoint "http://localhost:5000"

  def get_group_messages([group_id: group_id]), do: __MODULE__.get!("/groups/#{group_id}/messages.json")

  defp process_url(url), do: @endpoint <> url

  defp process_response_body(body), do: Poison.decode!(body)
end
