# SwiftPages
A swift implementation a tabbed page-like layout just like Instagram's toggle between grid and list views.
<br />
<br />

## Features

- A simple yet beautifully architected solution for management of paged-style view controllers.
- Dynamic loading of view controllers, allowing handing of high amounts of data without compromising memory.
- Highly customisable, all items have clean API’s to change them to any appearance or size.
- Can be sized and positioned anywhere within a view controller.
- Extensively documented code for quick understanding.

## Installation

### Installing with CocoaPods

### Manual Installation

Just Include the SwiftPages.swift file found on the demo in your project, and you’re good to go!

## Usage
Using **SwiftPages** in your project is very simple and straightforward. 

### Create a SwiftPages Instance

First create your SwiftPages instance, there are two ways to do it, as an **IBOoutlet** of a view of type SwiftPages from the storyboard, or programmatically:

<dl>
  <dt>As an IBOoutlet of a view of type SwiftPages from the storyboard</dt>
  <dd>Place a UIView in your view controller and assign its constraints, make its class be of type SwiftPages. Then control drag to your view controller as an IBOutlet.
</dd>

  <dt>As a fully programmatic SwiftPages view.</dt>
  <dd>Declare it in the viewDidLoad function of your view controller:
```swift
let swiftPagesView : SwiftPages!
```.</dd>
</dl>

### Initialization



## Customisation

## Example

## License
