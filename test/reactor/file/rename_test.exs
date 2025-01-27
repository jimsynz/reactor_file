defmodule Reactor.File.RenameTest do
  @moduledoc false
  use FileCase, async: true

  describe "rename" do
    defmodule RenameReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :source
      input :destination

      rename :rename do
        source input(:source)
        destination(input(:destination))
      end

      return :rename
    end

    test "when the "
  end
end
