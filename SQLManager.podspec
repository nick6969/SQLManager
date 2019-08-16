#
# Be sure to run `pod lib lint SQLManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SQLManager'
  s.version          = '0.2'
  s.summary          = 'Quick Opertion SQLite CRUD'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/nick6969/SQLManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hawhaw.ya@gmail.com' => 'hawhaw.ya@gmail.com' }
  s.source           = { :git => 'https://github.com/nick6969/SQLManager.git', :tag => s.version.to_s }
  s.swift_version    = "5.0"
  s.ios.deployment_target = '11.0'

  s.source_files = 'SQLManager/Classes/**/*'
  
  s.dependency 'FMDB', '2.6.2'
end
