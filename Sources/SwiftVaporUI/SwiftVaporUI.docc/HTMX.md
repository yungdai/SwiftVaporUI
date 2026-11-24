# Live updates with htmx

Update parts of a page from server-rendered fragments, with typed htmx modifiers.

## Overview

[htmx](https://htmx.org) lets any element send an HTTP request and swap the HTML that comes back into the page. It suits SwiftVaporUI well: every view can be returned from a route on its own, so a fragment is just a smaller view.

### Load htmx

Add ``HTMXScript`` to the document head. It loads a pinned htmx release from the jsDelivr CDN; pass `src:` to serve your own copy.

```swift
HTMLDocument(title: "Plants") {
    HTMXScript()
} body: {
    PlantList(plants: plants)
}
```

### Send requests from elements

Each modifier writes one `hx-*` attribute. ``HTMXSwap`` and ``HTMXTrigger`` name the values htmx understands, and accept a raw string for anything else.

```swift
Button("Load more", action: .plain)
    .hxGet("/plants?page=2")
    .hxTarget("#plant-list")
    .hxSwap(.beforeEnd)

Input(type: .search, name: "q")
    .hxGet("/search")
    .hxTrigger(.input.changed().delay(.milliseconds(300)), .search)
    .hxTarget("#results")
    .hxIndicator("#spinner")

PlantCount(count: count)
    .hxGet("/fragments/plant-count")
    .hxTrigger(.every(.seconds(5)))
    .hxSwap(.outerHTML)
```

The modifiers are `hxGet`, `hxPost`, `hxPut`, `hxPatch`, `hxDelete`, `hxTarget`, `hxSwap`, `hxTrigger`, `hxSelect`, `hxPushURL`, `hxIndicator`, `hxConfirm`, `hxInclude`, `hxVals`, `hxBoost`, `hxSwapOOB` and `hxDisabledElement`. Use `.hx(_:_:)` for any other `hx-*` attribute.

### Answer with a fragment or a page

Read the request's htmx headers with `req.isHTMX` or `req.htmx`. Most routes want ``Vapor/Request/fragmentOrPage(_:page:)``: it sends the fragment when htmx asks for it, and the full page when a browser opens the URL directly, follows a boosted link, or restores history.

```swift
app.get("plants", "count") { req in
    req.fragmentOrPage(PlantCount(count: await shelf.count())) { count in
        SiteLayout(title: "Plant count") { count }
    }
}
```

The response has `Vary: HX-Request`, so caches keep the two answers apart.

### Response headers

`HTTPHeaders.Name` has the htmx header names, such as `.hxTrigger`, `.hxRedirect`, `.hxRetarget` and `.hxReswap`, to steer htmx from the server.

```swift
var headers = HTTPHeaders()
headers.replaceOrAdd(name: .hxTrigger, value: "plant-added")
return HTMLResponse(headers: headers) { PlantRow(plant: plant) }
```

The showcase's `/htmx` page has live examples of each.

## Topics

### Loading htmx

- ``HTMXScript``

### Attribute values

- ``HTMXSwap``
- ``HTMXTrigger``

### Requests

- ``HTMXRequestDetails``
