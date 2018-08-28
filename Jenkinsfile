import groovy.transform.TupleConstructor

@Library('general-pipeline') _

def printBuildToolVersions(){
	def podVersion = (sh (returnStdout: true, script: 'pod --version')).trim()
	echo "CocoaPod version: $podVersion"
  sh "echo `xcodebuild -version`"
  echo (((sh (returnStdout: true, script: 'fastlane --version')) =~ /fastlane \d+\.\d+\.\d+/)[0])
}

def clone(device) {
    checkout changelog: true, poll: true, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "$device.udid/ios-emarsys-sdk"]], submoduleCfg: [], userRemoteConfigs: [[url: 'git@github.com:emartech/ios-emarsys-sdk.git']]]
}

def podi(device) {
    lock("pod") {
        sh "pod repo update"
        sh "cd $device.udid/ios-emarsys-sdk && pod install --verbose"
    }
}

def build(device) {
    lock(device.udid) {
        def uuid = UUID.randomUUID().toString()
        sh "cd $device.udid/ios-emarsys-sdk && xcodebuild -workspace ./EmarsysSDK.xcworkspace -scheme EmarsysSDK -configuration debug -derivedDataPath $uuid"
        sh "rm -rf $device.udid/ios-emarsys-sdk/$uuid"
    }
}

def test(device, scheme) {
	lock(device.udid) {
        def uuid = UUID.randomUUID().toString()
        try {
            sh "cd $device.udid/ios-emarsys-sdk && scan --scheme $scheme -d 'platform=$device.platform,id=$device.udid' --derived_data_path $uuid -o test_output/unit/ --clean"
        } catch (e) {
            currentBuild.result = 'FAILURE'
            throw e
        } finally {
        	sh "rm -rf $device.udid/ios-emarsys-sdk/$uuid"
          junit "$device.udid/ios-emarsys-sdk/test_output/unit/*.junit"
          archiveArtifacts "$device.udid/ios-emarsys-sdk/test_output/unit/*"
        }
    }
}

def testCore(device) {
    test(device, 'CoreTests')
}

def testMobileEngage(device) {
    test(device, 'MobileEngageTests')
}

def testPredict(device) {
    test(device, 'PredictTests')
}

def testEmarsysSDK(device) {
    test(device, 'EmarsysSDKTests')
}

@TupleConstructor()
class Device {
	def udid
	def platform
}

def doParallel(Closure action) {
    def devices = [
        [iPad_Pro: new Device(env.IPAD_PRO, 'iOS')],
        [iOS_9_3_Simulator: new Device(env.IOS93SIMULATOR, 'iOS Simulator')],
        [iOS_10_3_1_Simulator: new Device(env.IOS1031SIMULATOR, 'iOS Simulator')]
    ]
    def parallelActions = [:]
    for (device in devices) {
        device.each { key, value ->
            parallelActions[key] = {
                action(value)
            }
        }
    }
    parallelActions['failFast'] = false
    parallel parallelActions
}

node('master') {
    withSlack channel: 'jenkins', {
        stage('Init') {
            deleteDir()
            printBuildToolVersions()
        }
        stage('Git Clone') {
            doParallel(this.&clone)
        }
        stage('Pod install') {
            sh 'eval $(ssh-agent) && ssh-add ~/.ssh/ios-pod-private-repo'
            doParallel(this.&podi)
        }
        stage('Build') {
            doParallel(this.&build)
        }
        stage('Pod lint') {
        	sh "cd $env.IPAD_PRO/ios-emarsys-sdk && pod lib lint EmarsysSDK.podspec --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
        }
        stage('Pod lint NotificationService') {
            sh "cd $env.IPAD_PRO/ios-emarsys-sdk && pod lib lint EmarsysNotificationService.podspec --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
        }
        stage('Test Core') {
        	doParallel(this.&testCore)
        }
        stage('Test MobileEngage') {
        	doParallel(this.&testMobileEngage)
        }
        stage('Test Predict') {
        	doParallel(this.&testPredict)
        }
        stage('Test EmarsysSDK') {
        	doParallel(this.&testEmarsysSDK)
        }
        stage('Deploy to private pod repo') {
            sh "cd $env.IPAD_PRO/ios-emarsys-sdk && ./private-release.sh ${env.BUILD_NUMBER}.0.0"
        }
        stage('Deploy NotificationService to private pod repo') {
            sh "cd $env.IPAD_PRO/ios-emarsys-sdk && ./private-NSRelease.sh ${env.BUILD_NUMBER}.0.0"
        }
        stage('Finish') {
            echo "That is just pure awesome!"
        }
    }
}
