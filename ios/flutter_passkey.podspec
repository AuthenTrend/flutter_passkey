#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_passkey.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_passkey'
  s.version          = '1.0.4'
  s.summary          = 'A Flutter plugin for Passkey.'
  s.description      = <<-DESC
Flutter plugin for using Passkey easily.
                       DESC
  s.homepage         = 'https://github.com/AuthenTrend/flutter_passkey'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'AuthenTrend Technology Inc.' => 'joshua.lin@authentrend.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.frameworks = 'AuthenticationServices'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.5'
end
