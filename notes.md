* Create CeleryScript state struct replacing `Elixir.Macro.Env`.
* Update _every_ `Farmbot.CeleryScript.AST.Node` to work with said state struct.
  * remove requirement of every celery node requiring an execution context.
* init stuff
  * initialize heap structure. (Farmbot.CeleryScript.AST.Slicer.run(celeryscript))
  * initialize root scope to nil
  * if sequence, allocate memory for new closures.
* runtime stuff
  * on every node push a new scope onto the heap.
  * `env_get` + `env_set`
* heap needs to be passed into the runtime.
  * heap should be immutable after initial creation.
* Execute ???
  * allocate more data on the heap if it doesn't exist yet.
    * requires Heap metadata.
  * paramaters will need to be filled in by compiler (api/fe)
  * prevents null pointers on the stack and in var resolution.
* `sequence` pushes data (`paramater_decleration`, `variable_decleration`) on the stack when it starts, then pops back off when the sequences completes.
  * ACTUALLY: we need to use a stack pointer
  * this prevents stack overflows from infinite recursion.
  * compiler (the api) should prevent stack underflow.
* `paramater_decleration` pushes a null pointer onto the stack,
* `execute` populates that decleration for resolution.
