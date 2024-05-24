---
{
  "type": "post",
  "title": "Extreme procrastination: building a comment system",
  "description": "I was supposed to write a post about binary trees. But writing is hard, why write a blog post when you could be writing your own comment system?",
  "image": "/images/article-covers/extreme-procrastination.png",
  "draft": false,
  "published": "2019-12-03"
}
---

This is a story about procrastination and how I used it to make something (productive?).

When I started this blog I did it to force me to write more often. The reality is
I fear writing, I fear putting things out there, and this was a way to push me and face those fears and
come back as a better writer. 

Every time I was set out to write, my internal procrastinator found something more exciting to do. In this occasion,
the plan was to write about self balancing binary trees (and that post is still coming... soon). I was almost
starting writing when suddenly I realised I didn't have a comment system. "What kind of blog doesn't have
a comment system?" I thought. And that's how I decided I was going to integrate a comment system
in my blog.

Well, how hard could it be? I started looking around for solutions, open source and private, free 
and paid. There were many options. [Disqus](https://disqus.com/) was an easy choice. It's everywhere,
it has many features, easy to integrate and has a free plan (ad supported).

At that point, had I chose Disqus, I would have had a comment system ready in 10 minutes. But that would have 
been *too easy*, and I would have had to start writing! So I decided to keep looking, but I couldn't find anything that:

- It was free (or at least a generous free tier, that my blog was never going to surpass).
- It didn't have ads.
- It respected privacy.

"Shouldn't I just forget about comments? how likely am I to receive even one comment?" I thought. And
it definitely would have been wise, nevertheless I kept looking. At some point I figured I wasn't going
to find anything and decided to move on.

I started writing about binary trees, I was finally getting something done, I was proud of myself. After
ten minutes, reading the paragraph I wrote I said to myself: "this is crap, I am a shitty writer". And it's true,
I am a shitty writer, I know that, and that's precisely why I need to write, to get better. But it was too
late, my [instant gratification monkey](https://www.youtube.com/watch?v=arj7oStGLkU) took over.

Writing is hard and scary for me. Writing code is easy and fun, so I have a tendency to just diverge and code.
In this case, I found the perfect way, building a comment system that checks all my requirements.

## Tech stack

After a bit of research, I decided to give it a go, and decided on the tech stack.

### Frontend

Lately I have been using [elm](https://elm-lang.org/) to make my fronted experiments and I love it. It's
a small ML-based functional language. I hated frontend work until I found elm, and despite its limitations
I can say it makes me happy when I use it. What else can you ask a programming language for?

This decision was easy, like I had done many times, I would write a static elm app and use 
[netlify](https://www.netlify.com/) to build it and host it. If you have't heard about netlify, it's
awesome, I totally recommend you to have a look.

### Backend/storage

I looked around for free options on storage and there were not many. I was resigned to use a serverless
backend (probably Netlify functions) and [AWS DynamoDB](https://aws.amazon.com/dynamodb/). I wasn't
happy with this, so I let this project rest for a couple of days. 

Reading some random article in hacker news I found [FaunaDB](https://fauna.com/). 
FaunaDB provides document storage (MongoDB like) and it can create a graphql API for you. This was
really exciting, because this meant I could skip the serverless layer and use FaunaDB as backend and 
storage.

At the moment of writing this FaunaDB offers a generous free tier with:

- 5GB storage.
- 100K read operations per day.
- 50K write operations per day.
- 50 MB data transfer per day.

Meaning my needs are more than covered.

## High level features

The library is pretty simple, I implemented a MVP having the following features:

- You can add a comment.
- You can reply to a comment.
- Multiple discussions are supported, so each blog post has its own set of comments.
- Comments are anonymous, and no personal details are asked to comment.
- There is only one style, custom styling is not supported (yet).

If you want to see it in action, just scroll to the end of this post and comment! That
way we can see if it works!

### Data model and communication

Given the decision on using graphql our data model is expressed in the [graphql schema](https://github.com/danmarcab/comments/blob/master/schema.graphql
). It is extremely simple, and it is shown below:


```elm
type Comment (
    discussionId: String!,
    content: String!,
    parent: Comment
)

type Query (
    allComments: [Comment!] @index(name: "allComments"),
    commentsByDiscussionId(discussionId: String!): [Comment!] @index(name: "commentsByDiscussionId")
)
```

A comment has a `content` field to store the text the user entered, and a `discussionId` field, this is used to group comments by discussion/blog post. 
A comment also has an optional `parent` field that is used to group replies to a comment.

Upon uploading this schema, FaunaDB will create the collections and indexes needed to make the app work. See the
[installation instructions](https://github.com/danmarcab/comments/blob/master/README.md#provisioning-your-own-backend) for detailed steps. 

From the elm side, it just made sense to use the elm library `dillonkearns/elm-graphql`. This library generates
the type safe client side code from the graphql schema. This makes sure no data errors would happen in the
communication. With a little elm side UI work I had a first prototype running in a couple of hours.

### Interface or how can people use it

One of the main goals was ease of use, and even some painful manual steps remain, I think is not too bad.

There are 2 main steps, both detailed in the [github repo instructions](https://github.com/danmarcab/comments/blob/master/README.md#usage):

- Provision the DB/GraphQL API in FaunaDB. This involves manual steps, and it's probably what could be more subject to automate.
- Load the library from your html. This step is quite simple, you just need to load the compiled `js` library and start it like in the snippet below.

```html
<!doctype html>

<body style="width: 80%; margin: auto">
  <div></div>
  <script src="https://simple-comments.netlify.app/Comments.js"></script>
  <script>
      startComments((
        node: document.querySelector("div"),
        endpoint: "https://graphql.fauna.com/graphql",
        accessKey: "dasdj-your-own-access-key-fjpi",
        discussionId: "/posts/awesome-post-title"
      ));
  </script>
</body>
```

You can play around with the [test implementation](https://simple-comments.netlify.app/) or check how
I integrated it in my elm based blog using a custom element [here](https://github.com/danmarcab/danmarcab.com/blob/cc90a0d60d586e0a0ecc10d8ccdfddfb92579600/src/Pages/Post.elm#L61-L66)
and [here](https://github.com/danmarcab/danmarcab.com/blob/master/lib/comments.js).

## Conclusion

At the end, I think this detour made me think and learn new things, and I am quite happy about it.
As a byproduct I have a simple, limited comment system I can use in my blog, and the inspiration to
write this post.

It's way too easy to give in to the procrastination despair, thinking that if you continue like that
you'll never do anything meaningful. I feel this way pretty often, but I am trying to see the bright side
and value the good things I do when procrastinating, this post is the perfect example. You should do it too!

If you liked it (or not), please leave a comment below, this way I can keep improving.
