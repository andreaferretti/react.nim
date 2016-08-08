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
type
  ValueLink = ref object of RootObj
    value: string
    handler: proc(s: string)
  Search = ref object of StatelessComponent[ValueLink]
```

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
to your lifecycle procs the `this` instance of `ReactComponent[P, S]` (which
is `Search` in the example above), making it easier to write Javascript
methods.

## Using the DOM

The `reactdom` module exports factory methods for all DOM elements supported by
React. These are just procs that can be called with a variable number of
children (up to 4 for now).

Children can be `string`, `cstring` or other React nodes, for instance

```nim
import reactdom

let node = p(span("hello"), "world")
```

### `Attrs` and `attrs`

### `Style` and `style`

## The top level

To actually start an application, once you have defined a component, you can
call

```nim
let
  content = document.getElementById("some-id")
  ComponentInstance = myComponent(someProps)
ReactDOM.render(ComponentInstance, content)
```