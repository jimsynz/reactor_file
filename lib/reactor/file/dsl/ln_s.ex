defmodule Reactor.File.Dsl.LnS do
  @moduledoc """
  A `ln_s` DSL entity for the `Reactor.File` DSL extension.
  """
  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            guards: [],
            overwrite?: true,
            name: nil,
            revert_on_undo?: false,
            existing: nil,
            new: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          overwrite?: boolean,
          name: any,
          revert_on_undo?: boolean,
          existing: Template.t(),
          new: Template.t()
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :ln_s,
      describe: """
      Create a symbolic link from `existing` to `new`.

      Uses `File.ln_s/2`.
      """,
      target: __MODULE__,
      identifier: :name,
      args: [:name],
      recursive_as: :steps,
      entities: [
        arguments: [WaitFor.__entity__()],
        guards: [Guard.__entity__(), Where.__entity__()]
      ],
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
        existing: [
          type: Template.type(),
          required: true,
          doc: "The path to the existing file"
        ],
        new: [
          type: Template.type(),
          required: true,
          doc: "The path to the new file"
        ],
        overwrite?: [
          type: :boolean,
          required: false,
          default: true,
          doc: "Whether or not to overwrite the new if it already exists"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc:
            "Revert back to the initial state on undo (either by removing the new or by setting it back to it's original content)"
        ]
      ]
    }
end
