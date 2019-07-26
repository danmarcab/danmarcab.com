import {Elm} from "../src/Main.elm";

import posts from "../posts/*.txt";

const prod = process.env.NODE_ENV === 'production';

const flags = {
    showUnpublished: !prod,
    unparsedPosts: posts,
    viewport: { width: window.innerWidth, height: window.innerHeight}
};

const app = Elm.Main.init({flags: flags});

app.ports.downloadSvg.subscribe(svgId => {
    const svg = document.getElementById(svgId);
    const svgAsXML = (new XMLSerializer).serializeToString(svg);
    const dataURL = "data:image/svg+xml," + encodeURIComponent(svgAsXML);

    const dl = document.createElement("a");
    document.body.appendChild(dl); // This line makes it work in Firefox.
    dl.setAttribute("href", dataURL);
    dl.setAttribute("download", `${svgId}.svg`);
    dl.click();
});

