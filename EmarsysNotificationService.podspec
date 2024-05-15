Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysNotificationService'
	spec.version              = '3.5.0'
	spec.homepage             = 'https://github.com/emartech/ios-emarsys-sdk'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys NotificationService'
	spec.platform             = :ios, '11.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
            'Sources/include/EMSNotificationService.h',
            'Sources/Private/NSError+EMSCore.h',
            'Sources/Private/EMSServiceDictionaryValidator.h',
            'Sources/Private/EMSNotificationService+Actions.h',
            'Sources/Private/EMSNotificationService+Attachment.h',
            'Sources/Private/EMSNotificationService+PushToInApp.h',
            'Sources/Private/EMSNotificationService.h',
            'Sources/Private/MEDownloader.h',
            'Sources/MobileEngage/RichNotificationExtension/**/*.{h,m}'
        ]
    	spec.public_header_files  = [
            'Sources/include/EMSNotificationService.h'
    	]
	spec.libraries = 'z', 'c++'
end