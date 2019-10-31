defmodule LynxList.Links.Policies do
  alias LynxList.Links.LinkRecord
  alias LynxList.Types

  @spec can_view?(Types.id(), %LinkRecord{}) :: boolean
  def can_view?(_user_id, %LinkRecord{private: false}) do
    true
  end

  def can_view?(user_id, %LinkRecord{private: true} = link_record) do
    link_record.user.id == user_id
  end
end
