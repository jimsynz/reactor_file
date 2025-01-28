defmodule Reactor.File.Step.Rm do
  @arg_schema Spark.Options.new!(
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the directory to create"
                ]
              )

  @opt_schema Spark.Options.new!(
                revert_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Recreate the directory if the Reactor is undoing changes"
                ]
              )

  @moduledoc """
  A step which calls `File.rm/1`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}
  """
  use Reactor.Step
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of the `rm` step.
    """
    defstruct path: nil, before_stat: nil, original: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: nil | File.Stat.t(),
            original: Path.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, options} <- Spark.Options.validate(options, @opt_schema),
         {:ok, stat} <- maybe_stat(arguments[:path], [], context.current_step),
         {:ok, backup} <-
           maybe_backup_file(arguments[:path], stat, context, options[:revert_on_undo?]),
         :ok <- maybe_rm(arguments[:path], stat, context.current_step) do
      {:ok,
       %Result{
         path: arguments[:path],
         before_stat: stat,
         original: backup,
         changed?: not is_nil(stat)
       }}
    end
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
  def undo(result, _, _, _) when result.changed? == false, do: :ok

  def undo(result, _arguments, context, options) do
    if Keyword.get(options, :revert_on_undo?) do
      do_undo(result, context.current_step)
    else
      :ok
    end
  end

  defp maybe_backup_file(path, %{type: :regular}, context, true), do: backup_file(path, context)
  defp maybe_backup_file(_, _, _, _), do: {:ok, nil}

  defp maybe_rm(_path, nil, _), do: :ok
  defp maybe_rm(path, _, step), do: rm(path, step)

  defp do_undo(result, step) when is_nil(result.original), do: rm(result.path, step)

  defp do_undo(result, step) do
    with :ok <- cp(result.original, result.path, step),
         :ok <- chown(result.path, result.before_stat.uid, step),
         :ok <- chgrp(result.path, result.before_stat.gid, step),
         :ok <- chmod(result.path, result.before_stat.mode, step) do
      rm(result.original, step)
    end
  end
end
