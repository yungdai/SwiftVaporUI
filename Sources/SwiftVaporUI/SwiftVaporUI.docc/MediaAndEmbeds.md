# Media and embeds

Video, audio, responsive images, embedded pages and inline SVG.

## Overview

### Video and audio

``Video`` and ``Audio`` take a single `src`, or ``Source``s in several formats so the browser can pick one it plays. Anything else in the content is the fallback for browsers that cannot play media. Choose behaviour with ``MediaOptions`` and loading with ``MediaPreload``.

```swift
Video(poster: "/img/stall.jpg", options: [.controls, .muted, .playsInline]) {
    Source(src: "/media/stall.webm", type: "video/webm")
    Source(src: "/media/stall.mp4", type: "video/mp4")
    Track(src: "/media/stall.vtt", kind: .captions, language: "en", label: "English")
    Paragraph("Your browser cannot play this video.")
}
```

Browsers only autoplay muted media, so pair `.autoplay` with `.muted`.

### Responsive images

``Picture`` holds ``Source``s with `srcset`, `media` and `type`, and an ``Image`` fallback. The browser uses the first source that matches:

```swift
Picture {
    Source(srcset: "/img/stall.avif", type: "image/avif")
    Image(src: "/img/stall.jpg", alt: "The noodle stall at dusk")
}
```

### Embedded pages

``IFrame`` embeds another page. Its `title` is required because screen readers announce it. Frames load lazily by default, and `sandbox` restricts untrusted content.

### Inline SVG

``SVG`` sets up the drawing, and ``Element`` writes each shape. With a `label` the drawing is announced as an image; without one it is hidden from screen readers as decoration.

```swift
SVG(viewBox: "0 0 10 10", width: 16, height: 16, label: "Open") {
    Element("circle", attributes: ["cx": "5", "cy": "5", "r": "5", "fill": "seagreen"])
}
```

## Topics

- ``Video``
- ``Audio``
- ``Source``
- ``Track``
- ``MediaOptions``
- ``MediaPreload``
- ``Picture``
- ``IFrame``
- ``SVG``
