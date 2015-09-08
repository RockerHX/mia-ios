platform :ios, '7.0'
pod 'MBProgressHUD', '~> 0.9'
pod "AFNetworking", "~> 2.0"

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS'] = 'armv7 armv7s'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end