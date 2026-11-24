# Safety

How SwiftVaporUI protects pages from injected markup, and where you still need care.

## Overview

SwiftVaporUI escapes by default, so putting user input on a page is safe in the common cases.

- Text and attribute values are always HTML-escaped. `Paragraph(userInput)` cannot inject a tag.
- Attribute names and tag names are validated. Unsafe ones are dropped rather than written.
- Inline ``Style`` and ``Script`` content cannot close its own tag early, or hide the closing tag behind `<!--`.
- URL attributes (`href`, `src`, `action`, `formaction`, `poster`, `cite`, `data`) that use a `javascript:` or `vbscript:` scheme are written as `#`, so a link built from user input cannot run script.

### Where you still need care

- ``RawHTML`` writes its string exactly as given. Only use it with markup you wrote or otherwise trust.
- Other URLs are written as given. A `data:` URL or a link to another site is still allowed, so check untrusted URLs against the hosts you expect.
- `Button(_:action:)` with `.script(_:)` and inline ``Script`` run the code you give them. Never build that code from user input.
- Under a Content Security Policy, give inline scripts and styles a nonce, and CDN files an integrity hash. See below.
- ``HTMLEscaping`` exposes the escaping functions for custom views that write HTML themselves.

### Content Security Policy

A Content Security Policy (CSP) header tells the browser which scripts and styles it may run, so even markup that slips through cannot execute. The usual policy allows inline `<script>` and `<style>` elements by **nonce**: a random value, new for every response, that the header names and each allowed element carries.

`req.cspNonce` makes one per request, and the ``EnvironmentValues/cspNonce`` environment value hands it to every ``Script`` and ``Style`` on the page, and to the CSS that views such as ``ZStack`` and ``TabView`` write:

```swift
app.get { req in
    let nonce = req.cspNonce
    let policy = "default-src 'self'; script-src 'nonce-\(nonce)'; "
        + "style-src 'self' 'nonce-\(nonce)'; style-src-attr 'unsafe-inline'"
    return HTMLResponse(headers: ["Content-Security-Policy": policy]) {
        HomePage().environment(\.cspNonce, nonce)
    }
}
```

Pass `nonce:` to a single ``Script`` or ``Style`` to override the environment. ``CSPNonce/generate()`` makes a nonce outside a request.

Two things a nonce cannot cover:

- **`style` attributes.** Styling modifiers such as `.padding(_:)` write them. Allow them with `style-src-attr 'unsafe-inline'`, which lets markup set styles but not run script.
- **Inline event handlers.** ``ButtonAction/script(_:)`` writes an `onclick` attribute, which a nonce policy blocks. Use a ``Script`` with `addEventListener`, or a button action that needs no script, such as `.navigate(to:)`.

### Subresource Integrity

For a script or stylesheet on a CDN, pass its integrity hash. The browser refuses the file if it has changed. A hash adds `crossorigin="anonymous"`, which cross-origin integrity checks need, unless you choose another ``CrossOrigin`` mode.

```swift
Script(src: "https://cdn.example.com/chart.js", defer: true, integrity: "sha384-...")
Stylesheet(href: "https://cdn.example.com/kit.css", integrity: "sha384-...")
```

## Topics

- ``HTMLEscaping``
- ``RawHTML``
- ``CSPNonce``
- ``CrossOrigin``
