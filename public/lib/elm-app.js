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

    get appname() {
      return this._appname;
    }

    set appname(value) {
      if (this._appname === value) return;
      this._appname = value;
    }

    get flags() {
      return this._flags || {};
    }

    set flags(value) {
      if (this._flags === JSON.parse(decodeURIComponent(value))) return;
      this._flags = JSON.parse(decodeURIComponent(value));
    }

    connectedCallback() {
      const elmAppScript = document.createElement('script');
      const targetNode = document.createElement('div');
      const appname = this.appname;
      const flags = this.flags;

      elmAppScript.src = this.src;

      this.appendChild(targetNode);
      this.appendChild(elmAppScript);

      elmAppScript.addEventListener('load', function () {
        window[appname].init({ node: targetNode, flags: flags });
      }, false);
    }
  }
);
