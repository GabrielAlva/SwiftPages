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

**As an IBOoutlet of a view of type SwiftPages from the storyboard**
Place a UIView in your view controller and assign its constraints, make its class be of type SwiftPages. Then control drag to your view controller as an IBOutlet.
	
**As a fully programmatic SwiftPages view.**
Declare it in the viewDidLoad function of your view controller:
```swift
let swiftPagesView : SwiftPages!
```
Now set the desired position and size:
```swift
swiftPagesView = SwiftPages(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
```
### Initialization
SwiftPages can be initialize in one of two ways:

**Initialize with images as buttons on the top bar**
First create an array of strings, the strings will be the Storyboard ID's of the view controllers you would like to include:
```swift
var VCIDs : [String] = ["FirstVC", "SecondVC", "ThirdVC", "FourthVC", "FifthVC"]
```
Then create an array of UIImages which will correlate in order to the VC ID's array created above, it also have the same number of items as the aforementioned array:
```swift
var buttonImages : [UIImage] = [UIImage(named:"HomeIcon.png")!,
                                        UIImage(named:"LocationIcon.png")!,
                                        UIImage(named:"CollectionIcon.png")!,
                                        UIImage(named:"ListIcon.png")!,
                                        UIImage(named:"StarIcon.png")!]
```
Finally, use the `initializeWithVCIDsArrayAndButtonImagesArra` function with the two arrays created:
```swift
swiftPagesView.initializeWithVCIDsArrayAndButtonImagesArray(VCIDs, buttonImagesArray: buttonImages)
```

**Initialize with text on buttons**
First, alike with the image initialization, create an array of strings, the strings will be the Storyboard ID's of the view controllers you would like to include:
```swift
var VCIDs : [String] = ["FirstVC", "SecondVC", "ThirdVC", "FourthVC", "FifthVC"]
```
Then create an array of titles which will correlate in order to the VC ID's array created above, it must have the same number of items as the aforementioned array:
```swift
var buttonTitles : [String] = ["Home", "Places", "Photos", "List", "Tags"]
```
Finally, use the `initializeWithVCIDsArrayAndButtonTitlesArra` function with the two arrays created:
```swift
swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
```

## Customisation

## Example

## License
