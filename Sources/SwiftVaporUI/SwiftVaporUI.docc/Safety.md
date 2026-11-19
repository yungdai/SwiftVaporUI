# Safety

How SwiftVaporUI protects pages from injected markup, and where you still need care.

## Overview

SwiftVaporUI escapes by default, so putting user input on a page is safe in the common cases.

- Text and attribute values are always HTML-escaped. `Paragraph(userInput)` cannot inject a tag.
- Attribute names and tag names are validated. Unsafe ones are dropped rather than written.
- Inline ``Style`` and ``Script`` content cannot close its own tag early.

### Where you still need care

- ``RawHTML`` writes its string exactly as given. Only use it with markup you wrote or otherwise trust.
- Escaping does not validate URLs. Check the scheme before putting untrusted input into an `href` or `src`, so a `javascript:` URL cannot sneak in.
- `Button(_:action:)` with `.script(_:)` and inline ``Script`` run the code you give them. Never build that code from user input.
- ``HTMLEscaping`` exposes the escaping functions for custom views that write HTML themselves.

## Topics

- ``HTMLEscaping``
- ``RawHTML``
