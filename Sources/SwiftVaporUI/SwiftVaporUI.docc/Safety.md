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
- ``HTMLEscaping`` exposes the escaping functions for custom views that write HTML themselves.

## Topics

- ``HTMLEscaping``
- ``RawHTML``
