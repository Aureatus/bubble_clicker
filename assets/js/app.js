// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

/**
 * @type {Object.<string, import("phoenix_live_view").ViewHook>}
 */
let Hooks = {};
Hooks.Canvas = {
  mounted() {
    let canvas = this.el;
    let context = canvas.getContext("2d");

    this.pushEvent("Canvas:init", {}, (reply) => {
      const { data, cell_size } = reply;
      for (const cell of data) {
        const { value, x, y } = cell;
        const fill = value ? "black" : "blue";
        context.fillStyle = fill;

        context.fillRect(x, y, cell_size, cell_size);
      }
    });

    this.handleEvent("Canvas:update", (reply) => {
      const { data, cell_size } = reply;
      const { value, x, y } = data;

      const fill = value ? "black" : "blue";
      context.fillStyle = fill;

      context.fillRect(x, y, cell_size, cell_size);
    });
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  metadata: {
    click: (e) => {
      return {
        altKey: e.altKey,
        offsetX: e.offsetX,
        offsetY: e.offsetY,
      };
    },
  },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
