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
      const appName = this.appName;
      const flags = this.flags;

      elmAppScript.src = this.src;

      this.appendChild(targetNode);
      this.appendChild(elmAppScript);

      elmAppScript.addEventListener('load', function () {
        window[appName].init({node: targetNode, flags: flags});
      }, false);
    }
  }
);
