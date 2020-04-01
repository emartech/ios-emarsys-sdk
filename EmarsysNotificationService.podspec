Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysNotificationService'
	spec.version              = '2.5.0'
	spec.homepage             = 'https://github.com/emartech/ios-emarsys-sdk'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys NotificationService'
	spec.platform             = :ios, '11.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
	    'Sources/MobileEngage/RichNotificationExtension/**/*.{h,m}',
		'Sources/Core/Categories/NSError*.{h,m}',
		'Sources/include/EMSNotificationService.h'
	]
	spec.public_header_files  = [
        'Sources/include/EMSNotificationService.h'
	]
	spec.libraries = 'z', 'c++'
end