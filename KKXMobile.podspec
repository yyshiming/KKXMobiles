#
# Be sure to run `pod lib lint KKXMobile.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KKXMobile'
  s.version          = '0.1.0'
  s.summary          = '包括常用的扩展，基础功能'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/yyshiming/KKXMobile'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shiming' => 'zhangshiming86@163.com' }
  s.source           = { :git => 'git@github.com:yyshiming/KKXMobiile.git', :tag => s.version.to_s }
  
  s.requires_arc = true
  
  s.swift_versions = ['5.0']
  
  s.frameworks = "Foundation"
  s.ios.frameworks = "UIKit"

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*.{swift}'
  
  s.resource = 'Sources/KKXMobile/Resources/*'
  s.frameworks = 'UIKit'
end
