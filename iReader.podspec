Pod::Spec.new do |s|
  s.name         = "iReader"
  s.version      = "1.0.0"
  s.summary      = "A short description of iReader."
  s.author       = { "zhiyongzou" => "zhiyongzou" }
  s.homepage     = "https://github.com/Maks-Jago/iRead"
  s.source       = { :git => "https://github.com/Maks-Jago/iRead", :tag => s.version.to_s }
  s.platform      = :ios, '13.0'

  s.source_files = [
    'iRead/Source/*.{h,swift}',
    'iRead/Source/**/*.swift'
  ]

  s.dependency 'DTCoreText'
  s.dependency 'DTFoundation'
  s.dependency 'GCDWebServer'
  s.dependency 'SGQRCode'

  s.subspec 'DTCoreText' do |ss|
    ss.source_files         = 'ThirdPartyLibs/DTCoreText/**/*.{h,m}'
  end

  s.subspec 'DTFoundation' do |ss|
    ss.source_files         = 'ThirdPartyLibs/DTFoundation/**/*.{h,m}'
  end

  s.subspec 'GCDWebServer' do |ss|
    ss.source_files         = 'ThirdPartyLibs/GCDWebServer/**/*.{h,m}'
  end
  
  s.subspec 'SGQRCode' do |ss|
    ss.source_files         = 'ThirdPartyLibs/SGQRCode/**/*.{h,m}'
  end
end