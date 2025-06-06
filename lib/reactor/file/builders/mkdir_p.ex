defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.MkdirP do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(step, reactor) do
    Builder.add_step(
      reactor,
      step.name,
      {Reactor.File.Step.MkdirP, revert_on_undo?: step.revert_on_undo?},
      [Argument.from_template(:path, step.path) | step.arguments],
      guards: step.guards,
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
