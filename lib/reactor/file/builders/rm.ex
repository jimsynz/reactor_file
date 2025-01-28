defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Rm do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(step, reactor) do
    Builder.add_step(
      reactor,
      step.name,
      {Reactor.File.Step.Rm, revert_on_undo?: step.revert_on_undo?},
      [Argument.from_template(:path, step.path) | step.arguments],
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
