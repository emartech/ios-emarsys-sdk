Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysSDK'
	spec.version              = '2.0.0'
	spec.homepage             = 'https://github.com/emartech/ios-emarsys-sdk'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys iOS SDK'
	spec.platform             = :ios, '11.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
       'Core/**/*.{h,m}',
	   'MobileEngage/**/*.{h,m}',
       'Predict/**/*.{h,m}',
       'EmarsysSDK/**/*.{h,m}'
	]
	spec.exclude_files	  = 'MobileEngage/RichNotificationExtension/*'
	spec.public_header_files  = [
			'EmarsysSDK/Emarsys.h',
			'EmarsysSDK/EMSInAppProtocol.h',
			'EmarsysSDK/EMSInboxProtocol.h',
			'EmarsysSDK/EMSPredictProtocol.h',
			'EmarsysSDK/EMSPushNotificationProtocol.h',
			'EmarsysSDK/EMSBlocks.h',
			'EmarsysSDK/Setup/EMSConfig.h',
            'EmarsysSDK/Setup/EMSConfigBuilder.h',
			'Predict/Models/EMSCartItemProtocol.h',
            'Predict/Models/EMSCartItem.h',
            'Predict/Models/EMSProduct.h',
            'Predict/Models/EMSProductBuilder.h',
            'Predict/Recommendations/EMSLogicProtocol.h',
            'Predict/Recommendations/EMSLogic.h',
            'Predict/Recommendations/EMSRecommendationFilter.h',
            'Predict/Recommendations/EMSRecommendationFilterProtocol.h',
			'MobileEngage/IAM/EMSEventHandler.h',
			'MobileEngage/Inbox/EMSNotification.h',
			'MobileEngage/Inbox/EMSNotificationInboxStatus.h',
			'Core/Flipper/EMSFlipperFeatures.h',
			'MobileEngage/RichNotification/EMSUserNotificationCenterDelegate.h'
   	]
	spec.libraries = 'z', 'c++'
end