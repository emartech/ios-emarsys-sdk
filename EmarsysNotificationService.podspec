Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysNotificationService'
	spec.version              = '1.0.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys NotificationService'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'git@github.com:emartech/ios-emarsys-sdk.git', :commit => 'f1d8d7553d4c166b021990781fd73e95de2dbb99' }
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
