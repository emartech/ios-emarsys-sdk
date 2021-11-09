Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysSDKExposed'
	spec.version              = '3.1.1'
	spec.homepage             = 'https://github.com/emartech/ios-emarsys-sdk'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys iOS SDK'
	spec.platform             = :ios, '15.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
       'Sources/**/*.{h,m}'
	]
    spec.exclude_files	  = [
        'Sources/include/EMSNotificationService.h',
        'Sources/MobileEngage/RichNotificationExtension/**/*.{h,m}'
    ]
	spec.public_header_files  = [
	    'Sources/**/*.{h}'
   	]
	spec.libraries = 'z', 'c++'
end
