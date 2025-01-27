defmodule Reactor.File.Step.Rename do
  @arg_schema Spark.Options.new!(
                source: [
                  type: :string,
                  required: true,
                  doc: "The source file to rename"
                ],
                destination: [
                  type: :string,
                  required: true,
                  doc: "The destination file to rename"
                ]
              )

  @opt_schema Spark.Options.new!(
                overwrite?: [
                  type: :boolean,
                  required: false,
                  default: true,
                  doc: "Whether or not to overwrite the destination if it already exists"
                ],
                revert_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc:
                    "Revert back to the initial state on undo (either by removing the destination or by setting it back to it's original content)"
                ]
              )

  @moduledoc """
  Rename a file using `File.rename/2`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}
  """
  use Reactor.Step
  alias Reactor.File.OverwriteError
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of a `rename` step.
    """
    defstruct source: nil, destination: nil, before_stat: nil, changed?: nil

    @type t :: %__MODULE__{
            source: Path.t(),
            destination: Path.t(),
            before_stat: File.Stat.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, options} <- Spark.Options.validate(options, @opt_schema),
         {:ok, source_stat} <- maybe_stat(arguments[:source], [], context.current_step),
         {:ok, destination_stat} <- maybe_stat(arguments[:destination], [], context.current_step),
         :ok <-
           maybe_rename(
             arguments[:source],
             arguments[:destination],
             destination_stat,
             options[:overwrite?],
             context.current_step
           ) do
      {:ok,
       %Result{
         source: arguments[:source],
         destination: arguments[:destination],
         before_stat: source_stat,
         changed?: true
       }}
    end
  end

  defp maybe_rename(source, destination, _, true, step), do: rename(source, destination, step)
  defp maybe_rename(source, destination, nil, false, step), do: rename(source, destination, step)

  defp maybe_rename(source, destination, stat, false, step) when stat.type == :directory,
    do: rename(source, destination, step)

  defp maybe_rename(_source, destination, _stat, false, step) do
    {:error,
     OverwriteError.exception(
       step: step,
       file: destination,
       message: "destination already exists"
     )}
  end

  @doc false
  @impl true
  def can?(%{impl: {_, options}}, :undo) do
    with {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
      options[:revert_on_undo?]
    end
  end

  def can?(_, :undo), do: false
  def can?(step, capability), do: super(step, capability)

  @doc false
  @impl true
  def undo(result, _arguments, context, options) do
    if Keyword.get(options, :revert_on_undo?) && is_struct(result.before_stat, File.Stat) do
      do_undo(result, context.current_step)
    else
      :ok
    end
  end

  defp do_undo(result, step) do
    with :ok <- rename(result.destination, result.source, step),
         :ok <- chown(result.destination, result.before_stat.uid, step),
         :ok <- chgrp(result.destination, result.before_stat.gid, step) do
      chmod(result.destination, result.before_stat.mode, step)
    end
  end
end
