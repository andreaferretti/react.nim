import macros, dom, jsffi

{.experimental: "callOperator".}

when not defined(js):
  {.error: "React.nim is only available for the JS target" .}

type
  ReactGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDOMGlobal* {.importc.} = ref object of RootObj
    version*: cstring
  ReactDescriptor* [P, S] {.importcpp.} = ref object of RootObj
    render*: proc(): ReactNode
    componentWillMount*: proc(): void
    componentWillUnmount*: proc(): void
    componentDidMount*: proc(): void
    componentWillReceiveProps*: proc(nextProps: P): void
    shouldComponentUpdate*: proc(nextProps: P, nextState: S): bool
    componentWillUpdate*: proc(nextProps: P, nextState: S): bool
    componentDidUpdate*: proc(prevProps: P, prevState: S): bool
    getInitialState*: proc(): S
  ReactComponent* {.importc.} = ref object of RootObj
  ReactNode* {.importc.} = ref object of RootObj
  EventTarget* = ref object
    value*: cstring
  Event* = ref object
    target*: EventTarget
    `type`*: cstring
  Attrs* = ref object
    onClick*, onChange*: proc(e: Event)
    key*, `ref`*, dangerouslySetInnerHTML*: cstring

    accept*, acceptCharset*, accessKey*, action*, alt*, capture*,
      cellPadding*, cellSpacing*, challenge*, charSet*, cite*, classID*,
      className*, content*, contextMenu*, coords*, crossOrigin*,
      data*, dateTime*, default*, dir*, download*, encType*, form*,
      formAction*, formEncType*, formMethod*, formTarget*, frameBorder*,
      headers*, href*, hrefLang*, htmlFor*, httpEquiv*, icon*, id*, inputMode*,
      integrity*, keyParams*, keyType*, kind*, label*, lang*, list*,
      manifest*, media*, mediaGroup*, `method`*, name*, nonce*, pattern*,
      placeholder*, poster*, profile*, radioGroup*, rel*, role*, sandbox*,
      scope*, scrolling*, seamless*, shape*, sizes*, span*, src*, srcDoc*,
      srcLang*, srcSet*, summary*, tabIndex*, target*, title*, `type`*,
      useMap*, value*, wmode*, wrap*: cstring

    allowFullScreen*, allowTransparency*, async*, autoComplete*, autoFocus*,
      autoPlay*, checked*, contentEditable*, controls*, `defer`*, disabled*,
      draggable*, formNoValidate*, hidden*, loop*, multiple*, muted*,
      noValidate*, open*, preload*, readOnly*, required*, reversed*,
      scoped*, selected*, spellCheck*: bool

    colSpan*, cols*, height*, high*, low*, marginHeight*, marginWidth*, max*,
      maxLength*, min*, minLength*, optimum*, rowSpan*, rows*, size*, start*,
      step*, width*: cint

    style*: Style
  Style* = ref object
    color*, backgroundColor*: cstring
    marginTop*, marginBottom*, marginLeft*, marginRight*: int
  SvgAttrs* = ref object
    onClick*: proc(e: Event)
    key*, `ref`*, dangerouslySetInnerHTML*, className*, id*, stroke*,
      fill*, transform*, d*, points*: cstring
    cx*, cy*, r*, x*, y*, width*, height*, rx*, ry*, x1*, x2*, y1*,
      y2*, strokeWidth *: cint

{.push importcpp .}
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1, n2: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1, n2, n3: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: Attrs, n1, n2, n3, n4: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: SvgAttrs): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: SvgAttrs, n1: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: SvgAttrs, n1, n2: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: SvgAttrs, n1, n2, n3: auto): ReactNode
proc createElement*(react: ReactGlobal, tag: cstring, props: SvgAttrs, n1, n2, n3, n4: auto): ReactNode
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
    d.render = bindMethod renderComponent

  when compiles(componentWillMount(c)):
    d.componentWillMount = bindMethod componentWillMount

  when compiles(componentWillUnmount(c)):
    d.componentWillUnmount = bindMethod componentWillUnmount

  when compiles(componentDidMount(c)):
    d.componentDidMount = bindMethod componentDidMount

  when compiles(componentWillReceiveProps(c, c.props)):
    d.componentWillReceiveProps = bindMethod componentWillReceiveProps

  when compiles(shouldComponentUpdate(c, c.props, c.state)):
    d.shouldComponentUpdate = bindMethod shouldComponentUpdate
  elif compiles(shouldComponentUpdate(c, c.props)):
    d.shouldComponentUpdate = bindMethod shouldComponentUpdate

  when compiles(componentWillUpdate(c, c.props, c.state)):
    d.componentWillUpdate = bindMethod componentWillUpdate
  elif compiles(componentWillUpdate(c, c.props)):
    d.componentWillUpdate = bindMethod componentWillUpdate

  when compiles(componentDidUpdate(c, c.props, c.state)):
    d.componentDidUpdate = bindMethod componentDidUpdate
  elif compiles(componentDidUpdate(c, c.props)):
    d.componentDidUpdate = bindMethod componentDidUpdate

  when compiles(getInitialState(c.props)):
    d.getInitialState = proc(): auto =
      var this {.importc: "this", nodecl.}: C
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

proc `()`*[P](c: ReactComponent, p: P): ReactNode =
  React.createElement(c, p)