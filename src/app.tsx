import type { JSX } from "preact";
import { render } from "preact";

function App(): JSX.Element {
  return (
    <h1>Hello, World!</h1>
  );
}

render(<App />, document.body);
