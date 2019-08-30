defmodule LynxListWeb.LinkRecordView do
  use LynxListWeb, :view

  alias LynxList.Links.LinkRecord

  @spec link_record_json(%LinkRecord{}) :: map
  def link_record_json(%LinkRecord{} = link_record) do
    %{
      createdAt: link_record.inserted_at,
      description: link_record.description,
      id: link_record.id,
      parentLinkId: link_record.link.id,
      private: link_record.private,
      title: link_record.title,
      updatedAt: link_record.updated_at,
      url: link_record.link.url
    }
  end

  def render("show.json", %{link_record: %LinkRecord{} = link_record}) do
    %{
      linkRecord: link_record_json(link_record)
    }
  end
end
