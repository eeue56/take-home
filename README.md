# take-home

take-home is the world's first open-source project with all parts of the stack written in only Elm. The server-side code is Elm. The stylesheets are Elm. The client-side code is Elm.There's even a branch which shows how the build tools could be in Elm. We went all out to write as much as we could in Elm!

# Installation

## Requirements

- Node: `4.1.2`
- Elm: `0.16`

## How to run

- Clone the repo
- `npm install`
- `./run_prod.sh`

# Interesting parts

There's a lot in this project to take in. These are the important parts to look at!

## Support summary

In a brief summary, this program has support for the following in Elm

- Server-side programs
- [A web server](https://github.com/NoRedInk/take-home/blob/master/instance/server/Main.elm)
- [Database support in Elm](https://github.com/NoRedInk/take-home/blob/master/instance/server/User.elm)
- [Build tools](https://github.com/NoRedInk/take-home/pull/2)
- Env/JSON config support
- [Type-safe CSS](https://github.com/NoRedInk/take-home/blob/master/instance/server/Client/Admin/Styles.elm)
- [Server-side rendered client-side HTML](https://github.com/NoRedInk/take-home/blob/master/instance/server/Router.elm#L118)
- [Shared models between client and server side code](https://github.com/NoRedInk/take-home/tree/master/instance/server/Shared)
- [Server-side templating for data injection](https://github.com/NoRedInk/take-home/blob/master/instance/server/Client/StartTakeHome/App.elm#L22)

### Some extras

- Moment.js wrapper both client and server side
- Knox server side
- Uuid server side
- Nedb server side
- StartApp on the server

## Framework

While this project provides a good start place for anyone wishing to use full-stack Elm, it does not provide a "do everything" framework like Rails or Django just yet. There is work to make it more like a framework with scripting, but at this time it's not there yet.

# How does it work?

The server itself follows the Elm architecture. It uses a [modified startapp](https://github.com/NoRedInk/start-app) implementation. This means you have the following core functions

```elm
update : Action -> Model -> (Model, Effects Action)
routeIncoming : Connection -> Model -> (Model, Effects Action)
```

Notice how there's no longer a view. The update function is responsible for updating the model, while the router is responsible for writing replies to the client.

# Future work

## Create a sensible way of having global footers and headers

At the moment, it's hard to link things in like stylesheets in each view without having a monolithic view function that rendered conditionally. It would be much more ideal to support a way of linking CSS in a header that was somehow included everywhere

## Session data

There's no way of storing session data right now.

# FAQ

## Will this be used in production?

Yes! We're going to use in production.



# Credit

Fresheyeball provided the [PoC](https://github.com/Fresheyeball/elm-http-server) HTTP server implementation that we rewrote parts of [here](https://github.com/eeue56/servelm) and then applied to production!

rtfeldman provided CSS support through [elm-css](https://github.com/rtfeldman/elm-css)

# Awesome!

If you think this is awesome, why not apply to come [join us](https://www.noredink.com/jobs) make things?

---
[![NoRedInk](https://cloud.githubusercontent.com/assets/1094080/9069346/99522418-3a9d-11e5-8175-1c2bfd7a2ffe.png)][team]
[team]: http://noredink.com/about/team
