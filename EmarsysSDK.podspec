Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysSDK'
	spec.version              = '1.0.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Mobile Engage iOS SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'git@github.com:emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
         'Core/**/*.{h,m}',
	     'MobileEngage/**/*.{h,m}',
         'Predict/**/*.{h,m}',
         'EmarsysSDK/**/*.{h,m}'
	]
	spec.exclude_files	  = 'MobileEngage/RichNotificationExtension/*'
	spec.public_header_files  = [
   	]
	spec.libraries = 'z', 'c++'
end
