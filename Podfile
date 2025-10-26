# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'WJPhotoPicker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WJPhotoPicker
  
  # 图片加载
  pod 'SDWebImage', '~> 5.19'
  
  # WebP 支持
  pod 'SDWebImageWebPCoder', '~> 0.14'
  
  # 布局
  pod 'SnapKit', '~> 5.6'
  
  # 滑动面板
  pod 'FloatingPanel', '~> 2.6'

end

# 确保最低部署目标一致
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
