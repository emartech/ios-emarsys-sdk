Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysSDK'
	spec.version              = '2.5.2'
	spec.homepage             = 'https://github.com/emartech/ios-emarsys-sdk'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys iOS SDK'
	spec.platform             = :ios, '11.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
       'Sources/**/*.{h,m}'
	]
    spec.exclude_files	  = [
        'Sources/include/EMSNotificationService.h',
        'Sources/MobileEngage/RichNotificationExtension/**/*.{h,m}'
    ]
	spec.public_header_files  = [
        'Sources/include/Emarsys.h',
        'Sources/include/EMSInAppProtocol.h',
        'Sources/include/EMSInboxProtocol.h',
        'Sources/include/EMSPredictProtocol.h',
        'Sources/include/EMSGeofenceProtocol.h',
        'Sources/include/EMSPushNotificationProtocol.h',
        'Sources/include/EMSMessageInboxProtocol.h',
        'Sources/include/EMSInboxResult.h',
        'Sources/include/EMSMessage.h',
        'Sources/include/EMSBlocks.h',
        'Sources/include/EMSConfig.h',
        'Sources/include/EMSConfigBuilder.h',
        'Sources/include/EMSConfigProtocol.h',
        'Sources/include/EMSAppDelegate.h',
        'Sources/include/EMSCartItemProtocol.h',
        'Sources/include/EMSCartItem.h',
        'Sources/include/EMSProduct.h',
        'Sources/include/EMSLogicProtocol.h',
        'Sources/include/EMSLogic.h',
        'Sources/include/EMSRecommendationFilter.h',
        'Sources/include/EMSRecommendationFilterProtocol.h',
        'Sources/include/EMSEventHandler.h',
        'Sources/include/EMSNotification.h',
        'Sources/include/EMSNotificationInboxStatus.h',
        'Sources/include/EMSFlipperFeatures.h',
        'Sources/include/EMSUserNotificationCenterDelegate.h'
   	]
	spec.libraries = 'z', 'c++'
end