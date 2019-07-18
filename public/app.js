// Elm app
app = require("../src/Main.elm").Elm.Main;

posts = require("../posts/*.txt");

prod = process.env.NODE_ENV === 'production';

flags = {
    showUnpublished: !prod,
    unparsedPosts: posts
};

app.init({flags: flags});

