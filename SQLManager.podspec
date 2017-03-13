#
# Be sure to run `pod lib lint SQLManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'SQLManager'
s.version          = '0.1.4'
s.summary          = '用SQLite更簡潔好用的套件'
s.homepage         = 'https://github.com/nick6969/SQLManager'

s.license          = { :type => 'MIT' , :file => 'LICENSE' }
s.author           = { 'nick6969' => 'hawhaw.ya@gmail.com' }
s.source           = {
                        :git => "https://github.com/nick6969/SQLManager.git",
                        :tag => "0.1.4"
                     }

s.ios.deployment_target = '8.0'

s.source_files = 'SQLManager/Classes/**/*'
s.frameworks = 'UIKit', 'FMDB'
s.dependency 'FMDB'

end
