defmodule ExViber.TextMessage do
  defstruct [:timestamp, :token, :text, type: "text"]
end

defmodule ExViber.VideoMessage do
  defstruct [:timestamp, :token, :media, :size, :thumbnail, type: "video"]
end

defmodule ExViber.UserProfile do
  defstruct [:id, :name, :avatar, :country, :language]
end
