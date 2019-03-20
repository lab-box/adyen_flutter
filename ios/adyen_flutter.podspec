#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'adyen_flutter'
  s.version          = '0.0.1'
  s.summary          = 'An Adyen Flutter plugin for tha API integration'
  s.description      = <<-DESC
An Adyen Flutter plugin for tha API integration
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Adyen/Card'

  s.ios.deployment_target = '10.3'
end

