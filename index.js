import "elm-oembed";
import "./lib/comments.js";
import "./lib/code-editor.js";
import "./lib/elm-app.js";
import "./style.css";
// @ts-ignore
const { Elm } = require("./src/Main.elm");
const pagesInit = require("elm-pages");

pagesInit({
  mainElmModule: Elm.Main
});
