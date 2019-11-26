import "./native-shim.js";

customElements.define(
  "simple-comments",
  class extends HTMLElement {
    constructor() {
      super();
    }

    get discussionid() {
      return this._discussionid;
    }

    set discussionid(value) {
        console.log('setter', value)
      if (this._discussionid === value) return;
      this._discussionid = value;
    }

    connectedCallback() {
      let commentsScript = document.createElement('script');
      let targetNode = document.createElement('div');
      const discussionId = this.discussionId;

      commentsScript.src = "https://simple-comments.netlify.com/Comments.js";

      this.appendChild(targetNode);
      this.appendChild(commentsScript);

      commentsScript.addEventListener('load', function () {
          console.log(discussionId);

        startComments({
          node: targetNode,
          endpoint: "https://graphql.fauna.com/graphql",
          accessKey: "fnADd_TILIACAg200Tiovh3pYSj9IEyPSdw5lcxx",
          discussionId: discussionId,
          elmUIEmbedded: true
        });
      }, false);
    }
  }
);
