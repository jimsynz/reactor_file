defmodule Reactor.File.Dsl.Rename do
  @moduledoc """
  A `rename` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.WaitFor, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            destination: nil,
            overwrite?: true,
            name: nil,
            revert_on_undo?: false,
            source: nil,
            target: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          destination: Template.t(),
          overwrite?: boolean,
          name: any,
          revert_on_undo?: boolean,
          source: Template.t(),
          destination: Template.t()
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :rename,
      describe: """
      Renames a file.

      It can be used to move files (and directories) between directories. If
      moving a file, you must fully specify the destination filename, it is not
      sufficient to simply specify its directory.

      Uses `File.rename/2` behind the scenes.
      """,
      target: __MODULE__,
      identifier: :name,
      args: [:name],
      recursive_as: :steps,
      entities: [arguments: [WaitFor.__entity__()]],
      imports: [Argument],
      schema: [
        name: [
          type: :atom,
          required: true,
          doc:
            "A unique name for the step. Used when choosing the return value of the Reactor and for arguments into other steps"
        ],
        description: [
          type: :string,
          required: false,
          doc: "An optional description for the step"
        ],
        source: [
          type: Template.type(),
          required: true,
          doc: "The source path"
        ],
        destination: [
          type: Template.type(),
          required: true,
          doc: "The destination path"
        ],
        overwrite?: [
          type: :boolean,
          required: false,
          default: true,
          doc: "Whether or not to overwrite the target if it already exists"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc:
            "Revert back to the initial state on undo (either by removing the target or by setting it back to it's original content)"
        ]
      ]
    }
end
