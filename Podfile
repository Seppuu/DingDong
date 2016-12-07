platform :ios, '9.0'
use_frameworks!

target 'DingDong' do
    
#Objective-C
pod 'CTAssetsPickerController',  '~> 3.3.0'
pod 'DZNEmptyDataSet'
pod 'TWMessageBarManager'
pod 'MWPhotoBrowser'
pod 'UITextView+Placeholder', '~> 1.2'
pod 'StepSlider'
pod 'RMPZoomTransitionAnimator'
pod 'CLImageEditor/AllTools'


#Swift 3.0
pod 'SwiftyJSON', :git => 'https://github.com/acegreen/SwiftyJSON.git', :branch => 'swift3'
pod 'SnapKit', '~> 3.0.0'
pod 'Alamofire','~> 4.0.0'
pod 'Kingfisher','~> 3.1.0'
pod 'Ruler', '~> 1.0.0'
pod 'Proposer', '~> 1.0.0'
pod 'IQKeyboardManagerSwift', '4.0.6'
pod 'RealmSwift'
pod 'SwiftDate', '~> 4.0'
pod 'CryptoSwift'
pod 'KeyboardMan', '~> 1.0.0'
pod 'ReachabilitySwift', '~> 3'
pod 'PageMenu', :git => 'https://github.com/orazz/PageMenu.git'
pod 'EAIntroView', '~> 2.9.0'
pod 'RandomColorSwift'
pod 'MonkeyKing', '~> 1.1.0'



end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
