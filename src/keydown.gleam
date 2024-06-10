import gleam/io
import lustre
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html

pub fn main() {
  io.println("Hello from keydown!")
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

type Model {
  Model(keydown: String)
}

pub type Msg {
  Keydown(String)
}

pub type KeydownEvent

@external(javascript, "./keydown.ffi.mjs", "eventCode")
fn event_code(event: KeydownEvent) -> String

@external(javascript, "./keydown.ffi.mjs", "documentAddEventListener")
fn document_add_event_listener(
  type_: String,
  listener: fn(KeydownEvent) -> Effect(Msg),
) -> Nil

fn on_keydown(event: KeydownEvent) -> Effect(Msg) {
  io.debug(event)
  let code = event_code(event)
  io.debug(code)
  effect.from(fn(dispatch) { Keydown(code) |> dispatch })
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  let _ = document_add_event_listener("keydown", on_keydown)
  #(Model("N/A"), effect.none())
}

fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    Keydown(code) -> #(Model(keydown: code), effect.none())
  }
}

fn view(model: Model) {
  html.div([], [html.p([], [element.text(model.keydown)])])
}
