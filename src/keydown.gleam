import gleam/io
import lustre
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html

// MAIN ------------------------------------------------------------------------

pub fn main() {
  io.println("Hello from keydown!")
  let app = lustre.application(init, update, view)
  let assert Ok(send_to_runtime) = lustre.start(app, "#app", Nil)
  // (helpful comments from hayleigh from discord)
  // When we start an app we get back a function to send Actions to the runtime.
  // Actions are ways to communicate with the lustre runtime directly.
  document_add_event_listener("keydown", fn(event) {
    Keydown(event_code(event))
    // (from hayleigh from discord)
    // Because Actions are how we speak to the *runtime*, they encompass more
    // than just sending messages to our *application*. The dispatch action is
    // how we send messages
    |> lustre.dispatch
    |> send_to_runtime
  })
}

pub type KeydownEvent

@external(javascript, "./keydown.ffi.mjs", "eventCode")
fn event_code(event: KeydownEvent) -> String

@external(javascript, "./keydown.ffi.mjs", "documentAddEventListener")
fn document_add_event_listener(
  type_: String,
  listener: fn(KeydownEvent) -> Nil,
) -> Nil

// MODEL ------------------------------------------------------------------------

type Model {
  Model(keydown: String)
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(Model("N/A"), effect.none())
}

// UPDATE ------------------------------------------------------------------------

pub type Msg {
  Keydown(String)
}

fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    Keydown(code) -> #(Model(keydown: code), effect.none())
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) {
  html.p([], [element.text(model.keydown)])
}
