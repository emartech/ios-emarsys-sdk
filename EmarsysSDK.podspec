Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysSDK'
	spec.version              = '1.0.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Mobile Engage iOS SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
	     'MobileEngage/**/*.{h,m}',
	     'Core/**/*.{h,m}'
	]
	spec.exclude_files	  = 'MobileEngage/RichNotificationExtension/*'
	spec.public_header_files  = [
		'MobileEngage/MobileEngage.h',
		'MobileEngage/MobileEngageStatusDelegate.h',
		'MobileEngage/MEConfigBuilder.h',
        'MobileEngage/MEConfig.h',
	   	'MobileEngage/Flipper/MEFlipperFeatures.h',
        'MobileEngage/Inbox/MEInboxProtocol.h',
        'MobileEngage/Inbox/MENotification.h',
        'MobileEngage/Inbox/MENotificationInboxStatus.h',
        'MobileEngage/IAM/MEInApp.h',
        'MobileEngage/IAM/MEEventHandler.h',
        'MobileEngage/RichNotification/MEUserNotificationCenterDelegate.h'
   	]
	spec.libraries = 'z', 'c++'
end
