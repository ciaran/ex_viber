defmodule ExViber.TextMessage do
  defstruct [:timestamp, :token, :chat_id, :text, :keyboard, type: "text"]
end

defmodule ExViber.VideoMessage do
  defstruct [:timestamp, :token, :chat_id, :media, :size, :thumbnail, type: "video"]
end

defmodule ExViber.UserProfile do
  defstruct [:id, :name, :avatar, :country, :language]
end
