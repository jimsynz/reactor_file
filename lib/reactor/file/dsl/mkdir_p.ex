defmodule Reactor.File.Dsl.MkdirP do
  @moduledoc """
  A `mkdir_p` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.WaitFor, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            name: nil,
            path: nil,
            remove_on_undo?: false

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          name: any,
          path: Path.t(),
          remove_on_undo?: boolean
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :mkdir_p,
      describe: """
      Creates a directory and any intermediate directories which also must be created.

      Uses `File.mkdir_p/1` behind the scenes.
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
        path: [
          type: Template.type(),
          required: true,
          doc: "The path of the directory to create"
        ],
        remove_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Remove the created directory if the Reactor is undoing changes"
        ]
      ]
    }
end
