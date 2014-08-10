
rendering = require "../lib/rendering"

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
