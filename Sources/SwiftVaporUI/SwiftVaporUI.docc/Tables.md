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

Cells take a string or a builder, so they can hold links, badges or buttons. Pass `columnSpan` or `rowSpan` to make a cell cover several columns or rows, and give the table a title with ``TableCaption``, first inside the table. Set other cell attributes, such as `scope`, with `.attribute(_:_:)`.

```swift
Table {
    TableCaption("Friday's stage")
    TableRow {
        TableHeaderCell("Evening", rowSpan: 2)
        TableCell("19:00")
    }
    TableRow { TableCell("20:00") }
    TableFooter {
        TableRow { TableCell("Free entry", columnSpan: 2) }
    }
}
```

## Topics

- ``Table``
- ``TableHead``
- ``TableBody``
- ``TableFooter``
- ``TableRow``
- ``TableHeaderCell``
- ``TableCell``
- ``TableCaption``
