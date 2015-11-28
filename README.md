# take-home

take-home is the world's first open-source project with all parts of the stack written in only Elm. The server-side code is Elm. The stylesheets are Elm. The client-side code is Elm.There's even a branch which shows how the build tools could be in Elm.

# Interesting parts


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


# How does it work?

The server itself follows the Elm architecture. It uses a [modified startapp](https://github.com/NoRedInk/start-app) implementation. This means you have the following core functions

```elm
update : Action -> Model -> (Model, Effects Action)
routeIncoming : Connection -> Model -> (Model, Effects Action)
```

Notice how there's no longer a view. The update function is responsible for updating the model, while the router is responsible for writing replies to the client.

# FAQ

## Will this be used in production?

Yes! We're going to use in production.


# Credit

Fresheyeball provided the [PoC](https://github.com/Fresheyeball/elm-http-server) HTTP server implementation that we rewrote parts of [here](https://github.com/eeue56/servelm) and then applied to production!

rtfeldman provided CSS support through [elm-stylesheets](https://github.com/rtfeldman/elm-stylesheets)

# Awesome!

If you think this is awesome, why not apply to come join us make things?

---
[![NoRedInk](https://cloud.githubusercontent.com/assets/1094080/9069346/99522418-3a9d-11e5-8175-1c2bfd7a2ffe.png)][team]
[team]: http://noredink.com/about/team
