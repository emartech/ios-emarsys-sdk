Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysNotificationService'
	spec.version              = '2.1.0'
	spec.homepage             = 'https://github.com/emartech/ios-emarsys-sdk'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys NotificationService'
	spec.platform             = :ios, '11.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
	    'MobileEngage/RichNotificationExtension/**/*.{h,m}',
	    'Core/Categories/NSError*.{h,m}',
	    'Core/Validators/EMSDictionaryValidator*.{h,m}'
	]
	spec.public_header_files  = [
        'MobileEngage/RichNotificationExtension/EMSNotificationService.h'
	]
	spec.libraries = 'z', 'c++'
end