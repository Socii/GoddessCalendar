# GoddessCalendar
A model of the McKenna-Meyer Goddess Calendar; an accurate 13-month lunar calendar in which the months coincide with the lunar cycle.
The calendar was originally proposed by Terence McKenna in 1987, with accuracy updates added by Peter Meyer in 2012.

For more information, see [www.fractal-timewave.com](http://www.fractal-timewave.com/mmgc/mmgc.htm)

## Usage
Import `GoddessCalendar.framework` into your project.

User the `GoddessDate` struct to convert to and from a `Date` object.
```swift
import Foundation
import GoddessCalendar

let now = Date()
let date = GoddessDate(from: now)
print(date)
/// 1-114-8-8 MMG
```
