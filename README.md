# http-curl

The **HTTP API** for MultiValue BASIC, implemented over the **curl transport**.

```
your program ──> http  (the API)      ← this package provides it
                   │
                   └──> curl  (the transport)   ← this package depends on it
                          ├── mvx-lang/curl-cmd   the OS `curl` command
                          └── mvx-lang/curl       libcurl, in process
```

Depend on the virtual name `http` and you get the same calls on MVX, UniData,
UniVerse and jBASE, over whichever transport that platform can actually run.

## Why the split

`curl` is the **transport**: how bytes get to a host. `http` is the **API**: what
a program calls. Keeping them apart means the platform-shaped work — shell
quoting, jBASE having no shell at all, UniVerse needing `SH -c` — lives in one
place, in the transport, and is not repeated in every consumer.

It also lets the transport differ per platform without the API moving. UniVerse
has no in-process route to C, so it uses `curl-cmd`; UniData and jBASE can use
either.

**MVX is not supported yet**, and that is a missing transport rather than a
missing port: nothing provides `curl` there. `mvx-lang/curl` carries a libcurl
binding — TLS and redirects included — but declares `udt` only. The MVX arms
here are written and unverified, and the manifest leaves MVX out until there is
a transport to test them against.

## API

```basic
      CALL HTTP.GET(URL, RESP)
         RESP<1>  HTTP status  (0 if the transport failed)
         RESP<2>  response headers — reserved, see Limits
         RESP<3>  response body

      CALL HTTP.GETFILE(URL, PATH, RESP)
         RESP<1>  HTTP status  (0 if the transport failed)
```

`HTTP.GET` gives you the status **and** the body, which neither transport call
does alone — `HTTPGET` returns a body with no status, `HTTPGETFILE` a status
with no body.

`HTTP.GETFILE` is kept separate because a package tarball has no business being
assembled in memory first.

## Limits, honestly

**GET only, and no request headers.** The `curl` transport exposes exactly
`HTTPGET(url)` and `HTTPGETFILE(url, path)`, and neither can express a method or
a header. POST, PUT, custom headers and response headers all need the
*transport* surface to grow first; they are not something this layer can add on
its own. `RESP<2>` is reserved for when it does.

## Install

```
MVPKG install mvx-lang/http-curl
```

which pulls a `curl` provider if you have none. Or depend on the virtual name
from your own `mvpkg.json`:

```json
  "dependencies": ["http"]
```

## Naming

`http-curl` reads `<virtual>-<implementation>`, the same way `curl-cmd` is the
`curl` virtual implemented with the OS command.

## Licence

GPL-2.0-only. See [LICENSE](LICENSE).
