#
# Be sure to run `pod lib lint SwiftPages.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SwiftPages"
  s.version          = "1.0.0"
  s.summary          = "A swift implementation of a swipe between pages layout, just like Instagram's toggle between views."
  s.description      = <<-DESC
                       An optional longer description of SwiftPages

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/GabrielAlva/SwiftPages"
  # s.screenshots     = "https://github.com/GabrielAlva/SwiftPages/blob/master/Resources/Swift%20Pages%20iPhone%20mockups.png"
  s.license          = 'MIT'
  s.author           = { "Gabriel Alvarado" => "gabrielle.alva@gmail.com" }
  s.source           = { :git => "https://github.com/GabrielAlva/SwiftPages.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://github.com/GabrielAlva'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SwiftPages' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
