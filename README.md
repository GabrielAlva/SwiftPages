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
<br />
Place a UIView in your view controller and assign its constraints, make its class be of type SwiftPages. Then control drag to your view controller as an IBOutlet.
	
**As a fully programmatic SwiftPages view.**
<br />
Declare it in the viewDidLoad function of your view controller and set the desired position and size:
```swift
let swiftPagesView : SwiftPages!
swiftPagesView = SwiftPages(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
```

### Initialization
SwiftPages can be initialize in one of two ways:

**Initialize with images as buttons on the top bar:**
<br />
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

**Initialize with text on buttons:**
<br />
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

Once you have your `SwiftPages` instance you can customize the appearance of all item's using the class API's, to view the API list look for the `API's` Mark on the SwiftPages class. Below is a brief customization sample:
```swift
swiftPagesView.enableAeroEffectInTopBar(true)
swiftPagesView.setButtonsTextColor(UIColor.whiteColor())
swiftPagesView.setAnimatedBarColor(UIColor.whiteColor())
```

## Example

You can find a full example on usage and customization on the Xcode project attached to this repository.

## License

The MIT License (MIT)

**Copyright (c) 2015 Gabriel Alvarado (gabrielle.alva@gmail.com)**

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
