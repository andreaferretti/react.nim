import macros, dom, jsconsole, typetraits

type
  ReactGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDOMGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDescriptor* {.importcpp.}[P, S] = ref object of RootObj
    render* {.exportc.}: proc(): ReactNode
    componentWillMount* {.exportc.}: proc(): void
    componentDidMount* {.exportc.}: proc(): void
    componentWillReceiveProps* {.exportc.}: proc(nextProps: P): void
    getInitialState* {.exportc.}: proc(): S
  ReactComponent* {.importc.} = ref object of RootObj
  ReactNode* {.importc.} = ref object of RootObj
  Attrs* = ref object
    onClick* {.exportc.}: proc(): void
    id*, className* {.exportc.}: cstring
    style* {.exportc.}: Style
  Style* = ref object
    color* {.exportc.}, backgroundColor* {.exportc.}: cstring

{.push importcpp .}
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs): ReactNode {.varargs.}
proc createElement*(react: ReactGlobal, c: ReactComponent, props: ref RootObj): ReactNode {.varargs.}
proc createElement*(react: ReactGlobal, c: ReactComponent): ReactNode
proc createClass*(react: ReactGlobal, c: ReactDescriptor): ReactComponent
proc render*(reactDom: ReactDOMGlobal, node: ReactNode, el: Element)
{.pop.}

var
  React* {.importc, nodecl.}: ReactGlobal
  ReactDOM* {.importc, nodecl.}: ReactDOMGlobal

macro idString(x: untyped): auto = newStrLitNode($x)

template makeDomElement(x: untyped) =
  const tag {.gensym.} = idString(x)

  proc x*[A1](a: Attrs, el1: A1): ReactNode =
    React.createElement(tag, a, el1)
  proc x*[A1, A2](a: Attrs, el1: A1, el2: A2): ReactNode =
    React.createElement(tag, a, el1, el2)
  proc x*[A1, A2, A3](a: Attrs, el1: A1, el2: A2, el3: A3): ReactNode =
    React.createElement(tag, a, el1, el2, el3)
  proc x*[A1, A2, A3, A4](a: Attrs, el1: A1, el2: A2, el3: A3, el4: A4): ReactNode =
    React.createElement(tag, a, el1, el2, el3, el4)

  proc x*[A1](el1: A1): ReactNode =
    React.createElement(x, nil, el1)
  proc x*[A1, A2](el1: A1, el2: A2): ReactNode =
    React.createElement(x, nil, el1, el2)
  proc x*[A1, A2, A3](el1: A1, el2: A2, el3: A3): ReactNode =
    React.createElement(x, nil, el1, el2, el3)
  proc x*[A1, A2, A3, A4](el1: A1, el2: A2, el3: A3, el4: A4): ReactNode =
    React.createElement(x, nil, el1, el2, el3, el4)

makeDomElement(p)
makeDomElement(`div`)
makeDomElement(span)
makeDomElement(strong)

type
  Component*[P, S] = ref object of RootObj
    props*: P
    state*: S
    setState* {.importcpp.}: proc(s: S)
  StatelessComponent*[P] = Component[P, void]

macro findComponentType(body: stmt): auto =
  var tp: NimNode
  for x in body:
    if x.kind == nnkProcDef and $x[0] == "renderComponent":
      tp = x[3][1][1] # the type of the first arg of `render`
  if tp == nil:
    error("Could not find the `renderComponent` procedure")
  return tp

template addMethods(body: stmt): auto =
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

  when compiles(componentDidMount(c)):
    d.componentDidMount = proc(): auto =
      var this {.importc,nodecl.}: C
      componentDidMount(this)

  when compiles(componentWillReceiveProps(c, c.props)):
    d.componentWillReceiveProps = proc(nextProps: P): auto =
      var this {.importc,nodecl.}: C
      componentWillReceiveProps(this, nextProps)

  when compiles(getInitialState(c.props)):
    d.getInitialState = proc(): auto =
      var this {.importc,nodecl.}: C
      return getInitialState(this.props)

  return React.createClass(d)

macro defineComponent*(body: stmt): auto =
  result = newStmtList()
  for x in body:
    result.add(x)
  for x in getAst(addMethods(body)):
    result.add(x)