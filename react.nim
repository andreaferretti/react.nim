import macros, dom, jsconsole, typetraits

type
  ReactGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDOMGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDescriptor {.importcpp.}[P, S] = ref object of RootObj
    render* {.exportc.}: proc(): ReactNode
    componentWillMount* {.exportc.}: proc(): void
    componentWillUnmount* {.exportc.}: proc(): void
    componentDidMount* {.exportc.}: proc(): void
    componentWillReceiveProps* {.exportc.}: proc(nextProps: P): void
    shouldComponentUpdate* {.exportc.}: proc(nextProps: P, nextState: S): bool
    componentWillUpdate* {.exportc.}: proc(nextProps: P, nextState: S): bool
    componentDidUpdate* {.exportc.}: proc(prevProps: P, prevState: S): bool
    getInitialState* {.exportc.}: proc(): S
  ReactComponent* {.importc.} = ref object of RootObj
  ReactNode* {.importc.} = ref object of RootObj
  EventTarget* = ref object
    value*: cstring
  Event* = ref object
    target* {.exportc.}: EventTarget
    tp* {.exportc: "type".}: cstring
  Attrs* = ref object
    onClick* {.exportc.}, onChange* {.exportc.}: proc(e: Event)
    className* {.exportc.}, id* {.exportc.}, key* {.exportc.}, placeholder* {.exportc.},
      target* {.exportc.}, value* {.exportc.}: cstring
    checked* {.exportc.}, readOnly* {.exportc.}, required* {.exportc.}: bool
    style* {.exportc.}: Style
  Style* = ref object
    color* {.exportc.}, backgroundColor* {.exportc.}: cstring
    marginTop* {.exportc.}, marginBottom* {.exportc.}, marginLeft* {.exportc.}, marginRight* {.exportc.}: int


{.push importcpp .}
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1, n2: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1, n2, n3: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1, n2, n3, n4: auto): ReactNode
proc createElement*(react: ReactGlobal, c: ReactComponent, props: ref RootObj): ReactNode {.varargs.}
proc createElement*(react: ReactGlobal, c: ReactComponent): ReactNode
proc createClass*(react: ReactGlobal, c: ReactDescriptor): ReactComponent
proc render*(reactDom: ReactDOMGlobal, node: ReactNode, el: Element)
{.pop.}

var
  React* {.importc, nodecl.}: ReactGlobal
  ReactDOM* {.importc, nodecl.}: ReactDOMGlobal

type
  Component*[P, S] = ref object of RootObj
    props*: P
    state*: S
    setState* {.importcpp.}: proc(s: S)
  StatelessComponent*[P] = Component[P, void]

macro findComponentType(body: untyped): auto =
  var tp: NimNode
  if body.kind == nnkStmtList:
    for x in body:
      if x.kind == nnkProcDef and $x[0] == "renderComponent":
        tp = x[3][1][1] # the type of the first arg of `render`
  elif body.kind == nnkProcDef and $body[0] == "renderComponent":
    tp = body[3][1][1] # the type of the first arg of `render`
  if tp == nil:
    error("Could not find the `renderComponent` procedure")
  return tp

template addMethods(body: untyped): auto =
  type C = findComponentType(body)
  var c: C
  type P = type(c.props)
  when compiles(c.state):
    type S = type(c.state)
    var d = ReactDescriptor[P, S]()
  else:
    var d = ReactDescriptor[P, void]()

  when compiles(renderComponent(c)):
    d.render = proc(): auto =
      var this {.importc,nodecl.}: C
      return renderComponent(this)

  when compiles(componentWillMount(c)):
    d.componentWillMount = proc(): auto =
      var this {.importc,nodecl.}: C
      componentWillMount(this)

  when compiles(componentWillUnmount(c)):
    d.componentWillUnmount = proc(): auto =
      var this {.importc,nodecl.}: C
      componentWillUnmount(this)

  when compiles(componentDidMount(c)):
    d.componentDidMount = proc(): auto =
      var this {.importc,nodecl.}: C
      componentDidMount(this)

  when compiles(componentWillReceiveProps(c, c.props)):
    d.componentWillReceiveProps = proc(nextProps: P): auto =
      var this {.importc,nodecl.}: C
      componentWillReceiveProps(this, nextProps)

  when compiles(shouldComponentUpdate(c, c.props, c.state)):
    d.shouldComponentUpdate = proc(nextProps: P, nextState: S): auto =
      var this {.importc,nodecl.}: C
      return shouldComponentUpdate(this, nextProps, nextState)
  elif compiles(shouldComponentUpdate(c, c.props)):
    d.shouldComponentUpdate = proc(nextProps: P): bool =
      var this {.importc,nodecl.}: C
      return shouldComponentUpdate(this, nextProps)

  when compiles(componentWillUpdate(c, c.props, c.state)):
    d.componentWillUpdate = proc(nextProps: P, nextState: S): auto =
      var this {.importc,nodecl.}: C
      return componentWillUpdate(this, nextProps, nextState)
  elif compiles(componentWillUpdate(c, c.props)):
    d.componentWillUpdate = proc(nextProps: P): bool =
      var this {.importc,nodecl.}: C
      return componentWillUpdate(this, nextProps)

  when compiles(componentDidUpdate(c, c.props, c.state)):
    d.componentDidUpdate = proc(nextProps: P, nextState: S): auto =
      var this {.importc,nodecl.}: C
      return componentDidUpdate(this, nextProps, nextState)
  elif compiles(componentDidUpdate(c, c.props)):
    d.componentDidUpdate = proc(nextProps: P): bool =
      var this {.importc,nodecl.}: C
      return componentDidUpdate(this, nextProps)

  when compiles(getInitialState(c.props)):
    d.getInitialState = proc(): auto =
      var this {.importc,nodecl.}: C
      return getInitialState(this.props)

  return React.createClass(d)

macro defineComponent*(body: untyped): auto =
  if body.kind == nnkStmtList:
    result = body
    for x in getAst(addMethods(result)):
      result.add(x)
  else:
    result = newStmtList(body)
    for x in getAst(addMethods(body)):
      result.add(x)

macro attrs*(xs: varargs[untyped]): Attrs =
  let a = !"a"
  var body = quote do:
    var `a` {.noinit.}: Attrs
    {.emit: "`a` = {};" .}

  for x in xs:
    if x.kind == nnkExprEqExpr:
      let
        k = x[0]
        v = x[1]
      body.add(quote do:
        `a`.`k` = `v`
      )
    else:
      error("Expression `" & $x.toStrLit & "` not allowed in `attrs` macro")

  body.add(quote do:
    return `a`
  )

  result = quote do:
    proc inner(): Attrs {.gensym.} =
      `body`

    inner()

macro style*(xs: varargs[untyped]): Style =
  let a = !"a"
  var body = quote do:
    var `a` {.noinit.}: Style
    {.emit: "`a` = {};" .}

  for x in xs:
    if x.kind == nnkExprEqExpr:
      let
        k = x[0]
        v = x[1]
      body.add(quote do:
        `a`.`k` = `v`
      )
    else:
      error("Expression `" & $x.toStrLit & "` not allowed in `style` macro")

  body.add(quote do:
    return `a`
  )

  result = quote do:
    proc inner(): Style {.gensym.} =
      `body`

    inner()

proc `()`*[P](c: ReactComponent, p: P): ReactNode =
  React.createElement(c, p)