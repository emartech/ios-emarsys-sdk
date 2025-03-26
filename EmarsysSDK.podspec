Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysSDK'
	spec.version              = '3.8.0'
	spec.homepage             = 'https://github.com/emartech/ios-emarsys-sdk'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys iOS SDK'
	spec.platform             = :ios, '14.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
	    'Sources/Private/**/*.{h,m}',
        'Sources/**/*.{h,m}'
	]
    spec.exclude_files	  = [
        'Sources/include/EMSNotificationService.h',
        'Sources/Private/EMSServiceDictionaryValidator.h',
        'Sources/Private/EMSNotificationService+Actions.h',
        'Sources/Private/EMSNotificationService+Attachment.h',
        'Sources/Private/EMSNotificationService+PushToInApp.h',
        'Sources/Private/EMSNotificationService.h',
        'Sources/Private/MEDownloader.h',
        'Sources/MobileEngage/RichNotificationExtension/**/*.{h,m}'
    ]
    spec.resource_bundles   = {'EmarsysSDK' => ['Sources/PrivacyInfo.xcprivacy']}
	spec.public_header_files  = [
        'Sources/include/Emarsys.h',
        'Sources/include/EMSInAppProtocol.h',
        'Sources/include/EMSPredictProtocol.h',
        'Sources/include/EMSGeofenceProtocol.h',
        'Sources/include/EMSGeofence.h',
        'Sources/include/EMSGeofenceTrigger.h',
        'Sources/include/EMSPushNotificationProtocol.h',
        'Sources/include/EMSMessageInboxProtocol.h',
        'Sources/include/EMSInboxResult.h',
        'Sources/include/EMSInboxTag.h',
        'Sources/include/EMSMessage.h',
        'Sources/include/EMSBlocks.h',
        'Sources/include/EMSConfig.h',
        'Sources/include/EMSConfigBuilder.h',
        'Sources/include/EMSConfigProtocol.h',
        'Sources/include/EMSAppDelegate.h',
        'Sources/include/EMSCartItemProtocol.h',
        'Sources/include/EMSCartItem.h',
        'Sources/include/EMSProduct.h',
        'Sources/include/EMSProductProtocol.h',
        'Sources/include/EMSLogicProtocol.h',
        'Sources/include/EMSLogic.h',
        'Sources/include/EMSRecommendationFilter.h',
        'Sources/include/EMSRecommendationFilterProtocol.h',
        'Sources/include/EMSFlipperFeatures.h',
        'Sources/include/EMSInlineInAppView.h',
        'Sources/include/EMSNotificationInformation.h',
        'Sources/include/EMSOnEventActionProtocol.h',
        'Sources/include/EMSLogLevelProtocol.h',
        'Sources/include/EMSLogLevel.h',
        'Sources/include/EMSActionModelProtocol.h',
        'Sources/include/EMSAppEventActionModel.h',
        'Sources/include/EMSCustomEventActionModel.h',
        'Sources/include/EMSOpenExternalUrlActionModel.h'
   	]
	spec.libraries = 'z', 'c++'
end