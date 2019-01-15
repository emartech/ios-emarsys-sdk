import groovy.transform.TupleConstructor

@Library('general-pipeline') _

def printBuildToolVersions(){
	def podVersion = (sh (returnStdout: true, script: 'pod --version')).trim()
	echo "CocoaPod version: $podVersion"
  sh "echo `xcodebuild -version`"
}

def doParallel(devices, Closure action) {
    def parallelActions = [:]
    for (device in devices) {
        device.each { key, value ->
            parallelActions[key] = {
                action(key, value)
            }
        }
    }
    parallelActions['failFast'] = false
    parallel parallelActions
}

node('master') {
    timeout(30) {
        withSlack channel: 'jenkins', {
    			def buildVariant = "0"
    			def uuid = UUID.randomUUID().toString()
    			def derivedDataPath = "/tmp/$uuid"
            stage('Init') {
                deleteDir()
                printBuildToolVersions()
            }
            stage('Git Clone') {
    					checkout changelog: true, poll: true, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "$buildVariant/ios-emarsys-sdk"]], submoduleCfg: [], userRemoteConfigs: [[url: 'git@github.com:emartech/ios-emarsys-sdk.git']]]
            }
            stage('Pod install') {
                sh 'eval $(ssh-agent) && ssh-add ~/.ssh/ios-pod-private-repo'
    						lock("pod") {
    				        sh "pod repo update"
    				        sh "cd $buildVariant/ios-emarsys-sdk && pod install --verbose"
    				    }
            }
            stage('Build') {
    					sh "cd $buildVariant/ios-emarsys-sdk && xcodebuild -workspace ./EmarsysSDK.xcworkspace -scheme Tests -derivedDataPath $derivedDataPath -sdk iphoneos -allowProvisioningUpdates build-for-testing"
            }
            stage('Pod lint') {
            	sh "cd $buildVariant/ios-emarsys-sdk && pod lib lint EmarsysSDK.podspec --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
            }
            stage('Pod lint NotificationService') {
                sh "cd $buildVariant/ios-emarsys-sdk && pod lib lint EmarsysNotificationService.podspec --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
            }
            stage('Test EmarsysSDK') {
            	sh "cd $derivedDataPath/Build/Products ; zip -r Tests.zip Debug-iphoneos Tests_iphoneos12.0-arm64e.xctestrun"
    					sh "gcloud alpha firebase test ios run --test $derivedDataPath/Build/Products/Tests.zip --device model=iphonex,version=12.0,locale=en_GB --device model=iphone6s,version=11.4,locale=en_GB --device model=ipadmini4,version=12.0,locale=en_GB --quiet --project ems-mobile-sdk"
            }
            stage('Deploy to private pod repo') {
                sh "cd $buildVariant/ios-emarsys-sdk && ./private-release.sh ${env.BUILD_NUMBER}.0.0"
            }
            stage('Deploy NotificationService to private pod repo') {
                sh "cd $buildVariant/ios-emarsys-sdk && ./private-NSRelease.sh ${env.BUILD_NUMBER}.0.0"
            }
            stage('Finish') {
                echo "That is just pure awesome!"
            }
        }
    }
}
