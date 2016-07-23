import macros, dom, jsconsole

type
  ReactGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDOMGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDescriptor* {.importc.} = ref object of RootObj
    render* {.exportc.}: proc(): ReactNode
    componentWillMount* {.exportc.}: proc(): void
    componentDidMount* {.exportc.}: proc(): void
    getInitialState* {.exportc.}: proc(): RootObj
  ReactComponent* {.importc.} = ref object of RootObj
  ReactNode* {.importc.} = ref object of RootObj
  Attrs* {.importc.} = ref object
    onClick* {.exportc.}: proc(): void
    style* {.exportc.}: Style
  Style* {.importc.} = ref object
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

template makeDomElement(x: untyped) {.dirty.} =
  const tag = idString(x)

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

# proc render*(reactDom: ReactDOMGlobal, c: ReactComponent, el: Element) =
#   reactDom.render(React.createElement(c), el)

type
  BaseComponent*[P, S] = ref object of RootObj
    props*: P
    state*: S
  StatelessComponent*[P] = BaseComponent[P, void]

# type Backend*[P, S] = ref object of RootObj
#   forProps*, forState*: BaseComponent[P, S]
#
# proc props*[P, S](backend: Backend[P, S]): P = backend.forProps.props
#
# proc state*[P, S](backend: Backend[P, S]): S = backend.forState.state
#
# template setState*[P, S](backend: Backend[P, S], state: S) =
#   backend.forState.setState(state)

macro findComponentType(body: stmt): auto =
  var tp: NimNode
  for x in body:
    if x.kind == nnkProcDef and $x[0] == "renderComponent":
      tp = x[3][1][1] # the type of the first arg of `render`
  if tp == nil:
    error("Could not find the `renderComponent` procedure")
  return tp

template helper(body: stmt): auto =
  type T = findComponentType(body)
  var x: T
  var d = ReactDescriptor()

  when compiles(renderComponent(x)):
    d.render = proc(): auto =
      var this {.importc,nodecl.}: T
      return renderComponent(this)

  when compiles(componentWillMount(x)):
    d.componentWillMount = proc(): auto =
      var this {.importc,nodecl.}: T
      componentWillMount(this)

  when compiles(componentDidMount(x)):
    d.componentDidMount = proc(): auto =
      var this {.importc,nodecl.}: T
      componentDidMount(this)

  return React.createClass(d)

macro defineComponent*(body: stmt): auto =
  result = newStmtList()
  for x in body:
    result.add(x)
  for x in getAst(helper(body)):
    result.add(x)