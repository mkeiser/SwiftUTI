#
# Be sure to run `pod lib lint SwiftUTI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftUTI'
  s.version          = '1.0.6'
  s.summary          = 'A swift wrapper around Apples Universal Type Identifier functions.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

	This module makes it very simple to work with Apples Universal Type Identifiers.

                       DESC

  s.homepage         = 'https://github.com/mkeiser/SwiftUTI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mkeiser' => 'matthias@tristan-inc.com' }
  s.source           = { :git => 'https://github.com/mkeiser/SwiftUTI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.watchos.deployment_target = '2.0'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Sources/*'

  s.osx.framework = 'CoreServices'
  s.ios.framework = 'MobileCoreServices'

  # s.resource_bundles = {
  #   'SwiftUTI' => ['SwiftUTI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
