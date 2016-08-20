# React.nim

This library provides [React.js](https://facebook.github.io/react/) bindings for
Nim.

## Types

The fundamental building block exposed in React.nim is the type

```nim
type Component[P, S] = ...
```

where `P` are the props and `S` is the state, as well as the type alias

```nim
type StatelessComponent[P] = Component[P, void]
```

For your components, it is useful to define your own type aliases, such as in
the example app:

```nim
import react

type
  ValueLink = ref object of RootObj
    value: string
    handler: proc(s: string)
  Search = ref object of StatelessComponent[ValueLink]
```

The type `Component[P, S]` exists only on the Nim side and serves the purpose
of checking types on the props and the state of a component. The actual JS
object that is created by defining a component has the type `ReactComponent`.

Once one has a `ReactComponent`, one can instantiate it with props and
obtain a `ReactNode`. Also, there are factory functions such as `p` or `span`
to create `ReactNode` instances for DOM elements.

## Defining a component

Once you have your component types, use the `defineComponent` macro. Inside
the body of `defineComponent` you can use any function in the
[component lifecycle](https://facebook.github.io/react/docs/component-specs.html).

The only mandatory one - which is used to infer the types of props and state -
is `renderComponent`. You can use any other lifecycle method such as
`componentWillMount` or `componentDidUpdate`. If the state `S` is not `void`,
`getInitialState(props: P): S` is also mandatory.

An example without state, from the example app, is

```nim
proc makeSearch(): ReactComponent =
  defineComponent:
    proc renderComponent(s: Search): auto =
      `div`(
        attrs(className = "form-group"),
        input(attrs(
          className = "form-control",
          onChange = proc(e: react.Event) = s.props.handler($e.target.value),
          value = s.props.value,
          placeholder = "Filter here"
        ))
      )

let search = makeSearch()
```

As shown above, once you have the definition, you want to export a single
instance of the React class - here we do that by `let search = makeSearch()`.
The value `search` is what is used in Javascript to represent a component
class - hence calling `makeSearch()` two times will give rise to two
unrelated components, which is usually not what one wants.

### The `defineComponent` macro

The `defineComponent` takes care of binding the definitions of your lifecycle
procs as methods of an actual React.js component. At the same time, it passes
to your lifecycle procs the `this` instance of `Component[P, S]` (which
is `Search` in the example above), making it easier to write Javascript
methods.

### Passing props to component

In order to pass props to components, one can use the API

```nim
let node = React.createElement(myComponent, myProps)
```

To make this look more natural, as in JSX, the `()` operator is overloaded
on components, hence the above can be written as

```nim
let node = myComponent(myProps)
```

## Using the DOM

The `reactdom` module exports factory methods for all DOM elements supported by
React. These are just procs that can be called with a variable number of
children (up to 4 for now).

Children can be `string`, `cstring` or other React nodes, for instance

```nim
from reactdom import p, span

let node = p(span("hello"), "world")
```

The module `reactdom` exports *a lot* of functions, hence it is more convenient
to cherry-pick the ones to import.

Notice that tags such as ``div`` and ``object`` have to be written with
backticks.

### `Attrs` and `attrs`

HTML attributes can be passed to factory functions such as `p`, by adding
a first argument of type `Attrs`, which is defined by

```nim
Attrs* = ref object
  # actually, there are many more fields...
  onClick* {.exportc.}, onChange* {.exportc.}: proc(e: Event)
  className* {.exportc.}, id* {.exportc.}, key* {.exportc.}, placeholder* {.exportc.},
    target* {.exportc.}, value* {.exportc.}: cstring
  checked* {.exportc.}, readOnly* {.exportc.}, required* {.exportc.}: bool
  style* {.exportc.}: Style
```

It is actually not convenient to instantiate `Attrs` directly, because it has
many fields, and even unused fields would end up in the generated JS object,
with a value of `null`.

The `attrs` macro takes care of constructing an instance of `Attrs` while
only populating the field that are passed in. Hence, in order to add a class,
say `warning`, to the `span` in the example above, one would write

```nim
let node = p(span(attrs(className = "warning"), "hello"), "world")
```

### `Style` and `style`

One of the possible attributes is `style`, which has the type `Style` and can
be used to style HTML elements. The type `Style` is defined by

```nim
Style* = ref object
  # actually, there are many more fields...
  color* {.exportc.}, backgroundColor* {.exportc.}: cstring
  marginTop* {.exportc.}, marginBottom* {.exportc.}, marginLeft* {.exportc.},
    marginRight* {.exportc.}: int
```

A similar remark to `Attrs` applies: it is not convenient to create a `Style`
object directly - using the `style` macro will produce a JS object with only
the relevant fields populated.

Hence, to add a background color of red to the above example, one would write

```nim
let node = p(
  attrs(style = style(backgroundColor = "red")),
  span(attrs(className = "warning"), "hello"),
  "world")
```

### Using SVG

For SVG tags there is another module called `reactsvg`. It works the same as
`reactdom`, but functions defined in `reactsvg` accept a parameter of type
`SvgAttrs` instead of `Attrs`. This is defined by

```nim
SvgAttrs* = ref object
  # actually, there are many more fields...
  onClick* {.exportc.}: proc(e: Event)
  className* {.exportc.}, id* {.exportc.}, key* {.exportc.},
    stroke* {.exportc.}, fill* {.exportc.}, transform* {.exportc.}: cstring
```

As usual, it is more convenient to use the `svgAttrs` macro to generate
instances.

## The top level

To actually start an application, once you have defined a component, you can
call

```nim
import dom # from the Nim stdlib

let
  content = document.getElementById("some-id")
  ComponentInstance = myComponent(someProps)
ReactDOM.render(ComponentInstance, content)
```

## Events

To be documented

## Todo

The bindings are still not complete at this point. Things that are left:

* add more fields to the `SvgAttrs` and `Style` types
* distinguish between keyboard and mouse events, and make sure that one
  has access to all relevant information in the event callbacks
* reduce the boilerplate when defining components
* add dedicated types, together with converters to string, to generate SVG
  transforms and CSS dimensions and colors in a typesafe way
* generate [stateless functional components](https://facebook.github.io/react/docs/reusable-components.html#stateless-functions)
  when possible