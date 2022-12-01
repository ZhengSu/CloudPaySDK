#
# Be sure to run `pod lib lint CloudPay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CloudPay'
  s.version          = '0.3.0'
  s.summary          = '集成餐饮云收银台付款'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    移动端ios,接入收银台, 支持支付宝 微信等平台
                       DESC

  s.homepage         = 'https://github.com/ZhengSu/CloudPaySDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhengSu' => '15652618600@163.com' }
  s.source           = { :git => 'https://github.com/ZhengSu/CloudPaySDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  #s.source_files = 'CloudPay/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CloudPay' => ['CloudPay/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'WechatOpenSDK'
  s.dependency 'AlipaySDK-iOS'
  s.dependency 'WebViewJavascriptBridge'
  
  s.static_framework = true #指定pod加静态库标签
  s.vendored_frameworks = 'CloudPay.framework'

end
