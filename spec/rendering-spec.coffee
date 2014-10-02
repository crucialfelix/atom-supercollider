
rendering = require "../lib/rendering"

backtrace = [
  {
    caller: "0x1117b55c0"
    charPos: 2688
    file: "/SCClassLibrary/Common/Core/Error.sc"
    class: "Meta_MethodError"
    args: [
      {
        name: "this"
        value:
          asString: "DoesNotUnderstandError"
          class: "Meta_DoesNotUnderstandError"
      }
      {
        name: "what"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "receiver"
        value:
          asString: "an InfiniteGesture"
          class: "InfiniteGesture"
      }
    ]
    type: "Method"
    method: "new"
    address: "0x1117b3600"
  }
  {
    caller: "0x10bfae6c0"
    charPos: 4081
    file: "/SCClassLibrary/Common/Core/Error.sc"
    class: "Meta_DoesNotUnderstandError"
    args: [
      {
        name: "this"
        value:
          asString: "DoesNotUnderstandError"
          class: "Meta_DoesNotUnderstandError"
      }
      {
        name: "receiver"
        value:
          asString: "an InfiniteGesture"
          class: "InfiniteGesture"
      }
      {
        name: "selector"
        value:
          asString: "ohShit"
          class: "Symbol"
      }
      {
        name: "args"
        value:
          asString: "[ 2, 3, 4 ]"
          class: "Array"
      }
    ]
    type: "Method"
    method: "new"
    address: "0x1117b55c0"
  }
  {
    caller: "0x10f283140"
    charPos: 6836
    file: "/SCClassLibrary/Common/Core/Object.sc"
    class: "Object"
    args: [
      {
        name: "this"
        value:
          asString: "an InfiniteGesture"
          class: "InfiniteGesture"
      }
      {
        name: "selector"
        value:
          asString: "ohShit"
          class: "Symbol"
      }
      {
        name: "args"
        value:
          asString: "nil"
          class: "Nil"
      }
    ]
    type: "Method"
    method: "doesNotUnderstand"
    address: "0x10bfae6c0"
  }
  {
    caller: "0x10f61dd00"
    address: "0x10f283140"
    args: [
      name: "i"
      value:
        asString: "0"
        class: "Integer"
    ]
    context:
      class: "Meta_Collection"
      file: "/SCClassLibrary/Common/Collections/Collection.sc"
      charPos: 383
      method: "fill"

    type: "Function"
  }
  {
    caller: "0x10f282cc0"
    charPos: 879
    file: "/SCClassLibrary/Common/Math/Integer.sc"
    class: "Integer"
    args: [
      {
        name: "this"
        value:
          asString: "2"
          class: "Integer"
      }
      {
        name: "function"
        value:
          asString: "a Function"
          class: "Function"
      }
    ]
    vars: [
      name: "i"
      value:
        asString: "0"
        class: "Integer"
    ]
    type: "Method"
    method: "do"
    address: "0x10f61dd00"
  }
  {
    caller: "0x10fdb6200"
    charPos: 383
    file: "/SCClassLibrary/Common/Collections/Collection.sc"
    class: "Meta_Collection"
    args: [
      {
        name: "this"
        value:
          asString: "Array"
          class: "Meta_Array"
      }
      {
        name: "size"
        value:
          asString: "2"
          class: "Integer"
      }
      {
        name: "function"
        value:
          asString: "a Function"
          class: "Function"
      }
    ]
    vars: [
      name: "obj"
      value:
        asString: "[  ]"
        class: "Array"
    ]
    type: "Method"
    method: "fill"
    address: "0x10f282cc0"
  }
  {
    caller: "0x112931fd8"
    charPos: 969
    file: "/Extensions/quarks/felix/InfiniteGesture/InfiniteGesture.sc"
    class: "Meta_InfiniteGesture"
    args: [
      {
        name: "this"
        value:
          asString: "InfiniteGesture"
          class: "Meta_InfiniteGesture"
      }
      {
        name: "samplePaths"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "gui"
        value:
          asString: "false"
          class: "False"
      }
      {
        name: "loadBackup"
        value:
          asString: "false"
          class: "False"
      }
      {
        name: "sendMidiClock"
        value:
          asString: "false"
          class: "False"
      }
      {
        name: "installMidi"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "argTotal"
        value:
          asString: "nil"
          class: "Nil"
      }
    ]
    vars: [
      {
        name: "ig"
        value:
          asString: "an InfiniteGesture"
          class: "InfiniteGesture"
      }
      {
        name: "b"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "w"
        value:
          asString: "nil"
          class: "Nil"
      }
    ]
    type: "Method"
    method: "new"
    address: "0x10fdb6200"
  }
  {
    caller: "0x1127d7dd8"
    address: "0x112931fd8"
    source: "InfiniteGesture.new "
    type: "Function"
  }
  {
    caller: "0x10fe87900"
    address: "0x1127d7dd8"
    type: "Function"
  }
  {
    caller: "0x10fe873c0"
    charPos: 4428
    file: "/SCClassLibrary/Common/Core/Function.sc"
    class: "Function"
    args: [
      name: "this"
      value:
        asString: "a Function"
        class: "Function"
    ]
    vars: [
      {
        name: "result"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "thread"
        value:
          asString: "a Thread"
          class: "Thread"
      }
      {
        name: "next"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "wasInProtectedFunc"
        value:
          asString: "false"
          class: "False"
      }
    ]
    type: "Method"
    method: "prTry"
    address: "0x10fe87900"
  }
  {
    caller: "0x1127d9b88"
    charPos: 4309
    file: "/SCClassLibrary/Common/Core/Function.sc"
    class: "Function"
    args: [
      {
        name: "this"
        value:
          asString: "a Function"
          class: "Function"
      }
      {
        name: "handler"
        value:
          asString: "a Function"
          class: "Function"
      }
    ]
    vars: [
      name: "result"
      value:
        asString: "nil"
        class: "Nil"
    ]
    type: "Method"
    method: "try"
    address: "0x10fe873c0"
  }
  {
    caller: "0x1129326f8"
    address: "0x1127d9b88"
    args: [
      {
        name: "guid"
        value:
          asString: "ee037ee0-2134-11e4-a9ce-99392c7133f0"
          class: "String"
      }
      {
        name: "escapedCode"
        value:
          asString: "InfiniteGesture.new"
          class: "String"
      }
      {
        name: "executingPath"
        value:
          asString: "/Users/crucial/sctest/test.scd"
          class: "String"
      }
      {
        name: "returnResultAsString"
        value:
          asString: "true"
          class: "True"
      }
      {
        name: "reportError"
        value:
          asString: "false"
          class: "False"
      }
    ]
    vars: [
      {
        name: "code"
        value:
          asString: "InfiniteGesture.new"
          class: "String"
      }
      {
        name: "compiled"
        value:
          asString: "a Function"
          class: "Function"
      }
      {
        name: "result"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "error"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "saveExecutingPath"
        value:
          asString: "nil"
          class: "Nil"
      }
    ]
    type: "Function"
  }
  {
    caller: "0x1112defc0"
    address: "0x1129326f8"
    source: "Library.at(\\supercolliderjs)"
    type: "Function"
  }
  {
    caller: "0x1108584c0"
    charPos: 15028
    file: "/SCClassLibrary/Common/Core/Kernel.sc"
    class: "Interpreter"
    args: [
      name: "this"
      value:
        asString: "an Interpreter"
        class: "Interpreter"
    ]
    vars: [
      {
        name: "res"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "func"
        value:
          asString: "a Function"
          class: "Function"
      }
      {
        name: "code"
        value:
          asString: "Library.at(\\supercolliderjs)"
          class: "String"
      }
      {
        name: "doc"
        value:
          asString: "nil"
          class: "Nil"
      }
      {
        name: "ideClass"
        value:
          asString: "nil"
          class: "Nil"
      }
    ]
    type: "Method"
    method: "interpretPrintCmdLine"
    address: "0x1112defc0"
  }
  {
    charPos: 9915
    file: "/SCClassLibrary/Common/Core/Kernel.sc"
    class: "Process"
    args: [
      name: "this"
      value:
        asString: "a Main"
        class: "Main"
    ]
    type: "Method"
    method: "interpretPrintCmdLine"
    address: "0x1108584c0"
  }
]

describe "rendering an error", ->

  errors =
    Error:
      what: "Error"
      error:
        errorString: "ERROR: error string"
    DoesNotUnderstand:
      what: "DoesNotUnderstand"
      error:
        errorString: "ERROR: does not understand"
        receiver:
          class: "Integer"
          asString: "5"
        args: [
          {class: "Integer", asString: "2"}
          {class: "Integer", asString: "5"}
        ]


  for name, err of errors
    it "should render each property of #{name}", ->
      out = rendering.renderError(err)
      expect(out).toBeTruthy()

  it "should render the backtrace", ->
    out = rendering.formatBacktrace(backtrace)
    expect(out).toBeTruthy()


describe "rendering a SyntaxError", ->

  error =
    type: 'SyntaxError'
    errorTime: new Date()
    error:
      code: "source code here"
      file: "/Users/moi/supercollider/file.scd"

  it "should render the error", ->
    out = rendering.renderError(error)
    expect(out).toBeTruthy()


describe "stdout styling", ->

  it "should remove prompts", ->
    input = "\nsc3> \nsomething\n"
    output = rendering.cleanStdout(input)
    expect(output).not.toContain("sc3>")

  it "should remove terminal escape sequences", ->
    esc = String.fromCharCode(27)
    input = "blahblah#{esc}[H#{esc}[2J"
    output = rendering.cleanStdout(input)
    expect(output).not.toContain(esc)
    expect(output).not.toContain("H")
    expect(output).not.toContain("2J")
