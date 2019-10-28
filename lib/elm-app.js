import "./native-shim.js";

customElements.define(
  "elm-app",
  class extends HTMLElement {
    constructor() {
      super();
    }

    get src() {
      return this._src;
    }

    set src(value) {
      if (this._src === value) return;
      this._src = value;
    }

    get appName() {
      return this._appName;
    }

    set appName(value) {
      if (this._appName === value) return;
      this._appName = value;
    }

    connectedCallback() {
      let shadow = this.attachShadow({ mode: "open" });
      let elmAppScript = document.createElement('script');
      let targetNode = document.createElement('div');
      const appName = this.appName;

      elmAppScript.src = this.src;

      shadow.appendChild(targetNode);
      shadow.appendChild(elmAppScript);

      elmAppScript.addEventListener('load', function () {
        window[appName].init({node: targetNode});
      }, false);
    }
  }
);
