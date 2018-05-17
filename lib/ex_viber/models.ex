defmodule ExViber.TextMessage do
  defstruct [:timestamp, :token, :chat_id, :text, :keyboard, type: "text"]
end

defmodule ExViber.RichMediaMessage do
  defstruct [:timestamp, :token, :chat_id, :alt_text, :rich_media, :keyboard, type: "rich_media"]
end

defmodule ExViber.KeyboardMessage do
  defstruct [:timestamp, :token, :keyboard]
end

defmodule ExViber.VideoMessage do
  defstruct [:timestamp, :token, :chat_id, :media, :size, :thumbnail, :keyboard, type: "video"]
end

defmodule ExViber.PictureMessage do
  defstruct [:timestamp, :token, :chat_id, :media, :text, :thumbnail, :keyboard, type: "picture"]
end

defmodule ExViber.UrlMessage do
  defstruct [:timestamp, :token, :chat_id, :media, :keyboard, type: "url"]
end

defmodule ExViber.UserProfile do
  defstruct [:id, :name, :avatar, :country, :language, :api_version]
end
