defmodule VK do
  alias VK.Api

  def get_group_messages(group_id, timeout \\ 10_000) do
    Api.make_request(:get_group_messages, [group_id: group_id], timeout)
  end
end
