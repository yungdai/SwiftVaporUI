# Tables

Build tables from rows of data.

## Overview

Table views map one to one onto the HTML table elements. Combine them with ``ForEach`` to render a row per record, and compute totals with ordinary Swift.

```swift
let total = harvest.reduce(0) { $0 + $1.kilograms }

Table {
    TableHead {
        TableRow {
            TableHeaderCell("Crop")
            TableHeaderCell("Kilograms")
        }
    }
    TableBody {
        ForEach(harvest) { row in
            TableRow {
                TableCell(row.crop)
                TableCell(row.kilograms.formatted())
            }
            .class("highlight", when: row.kilograms > 10)
        }
    }
    TableFooter {
        TableRow {
            TableCell("Total")
            TableCell(total.formatted())
        }
    }
}
.class("data-table")
```

Cells take a string or a builder, so they can hold links, badges or buttons. Set cell attributes such as `colspan` or `scope` with `.attribute(_:_:)`.

## Topics

- ``Table``
- ``TableHead``
- ``TableBody``
- ``TableFooter``
- ``TableRow``
- ``TableHeaderCell``
- ``TableCell``
