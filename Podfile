source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'
use_frameworks!

target 'FlickrImageSearch' do
    pod 'Alamofire'
    pod 'AlamofireObjectMapper'
    pod 'Kingfisher'
    pod 'SwiftOverlays'
end

target 'FlickrImageSearchTests' do
    pod 'Alamofire'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
	    target.build_configurations.each do |config|
	        config.build_settings['SWIFT_VERSION'] = '3.0'
	    end
	end
end