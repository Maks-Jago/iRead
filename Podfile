# cocoapods update
# sudo gem install cocoapods -version
# https://guides.cocoapods.org/syntax/podfile.html

install! 'cocoapods',
         :warn_for_unused_master_specs_repo => false

platform :ios, '10.0'

inhibit_all_warnings!

workspace 'iRead.xcworkspace'

# debug_pods
def debug_pods
  pod 'FLEX', '~> 4.1.1', :configurations => ['Debug'], :modular_headers => true
end

# common_pods
def common_pods
  pod 'IRHexColor', '~> 0.0.5'
  pod 'AEXML', '~> 4.5.0'
  pod 'SSZipArchive', '~> 2.4.2'
  pod 'FMDB', '~> 2.7.5', :modular_headers => true
end

# local_pods
def local_pods
  pod 'SGQRCode', :path => './ThirdPartyLibs/SGQRCode', :modular_headers => true
  pod 'DTCoreText', :path => './ThirdPartyLibs/DTCoreText', :modular_headers => true
  pod 'DTFoundation', :path => './ThirdPartyLibs/DTFoundation', :modular_headers => true
  pod "GCDWebServer/WebUploader", :path => './ThirdPartyLibs/GCDWebServer', :modular_headers => true
end

# common_pods
common_pods

# ==================================== Targets ==================================== #

target 'iRead' do

  # debug pods
  debug_pods
  local_pods
  
  # for iRead
  pod 'SnapKit', '~> 5.0.1'
  pod 'CMPopTipView', '~> 2.3.2', :modular_headers => true
  pod 'PKHUD', '~> 5.3.0'
  pod 'ReachabilitySwift', '~> 5.0.0'
  pod 'Alamofire', '~> 5.5'
  pod 'SVProgressHUD', '~> 2.2.5', :modular_headers => true

end

# https://github.com/CocoaPods/CocoaPods/issues/8069
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
            end
        end
    end
end
