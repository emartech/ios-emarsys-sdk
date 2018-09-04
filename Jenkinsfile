import groovy.transform.TupleConstructor

@Library('general-pipeline') _

@TupleConstructor()
class Device {
	def udid
	def platform
}

def printBuildToolVersions(){
	def podVersion = (sh (returnStdout: true, script: 'pod --version')).trim()
	echo "CocoaPod version: $podVersion"
  sh "echo `xcodebuild -version`"
  echo (((sh (returnStdout: true, script: 'fastlane --version')) =~ /fastlane \d+\.\d+\.\d+/)[0])
}

def clone(key, device) {
    checkout changelog: true, poll: true, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "$key/ios-emarsys-sdk"]], submoduleCfg: [], userRemoteConfigs: [[url: 'git@github.com:emartech/ios-emarsys-sdk.git']]]
}

def podi(key, device) {
    lock("pod") {
        sh "pod repo update"
        sh "cd $key/ios-emarsys-sdk && pod install --verbose"
    }
}

def build(key, device) {
    lock(device.udid) {
        def uuid = UUID.randomUUID().toString()
        sh "cd $key/ios-emarsys-sdk && xcodebuild -workspace ./EmarsysSDK.xcworkspace -scheme EmarsysSDK -configuration debug -derivedDataPath $uuid"
        sh "rm -rf $key/ios-emarsys-sdk/$uuid"
    }
}

def test(key, device, scheme) {
	lock(device.udid) {
			def action = {
				def uuid = UUID.randomUUID().toString()
				try {
						sh "cd $key/ios-emarsys-sdk && scan --scheme $scheme -d 'platform=$device.platform,id=$device.udid' --derived_data_path $uuid -o test_output/unit/ --clean"
				} catch (e) {
						currentBuild.result = 'FAILURE'
						throw e
				} finally {
					sh "rm -rf $key/ios-emarsys-sdk/$uuid"
					junit "$key/ios-emarsys-sdk/test_output/unit/*.junit"
					archiveArtifacts "$key/ios-emarsys-sdk/test_output/unit/*"
				}
			}

			if(device.platform == 'iOS Simulator') {
        lock('iOS Simulator') {
					sh "xcrun simctl boot $device.udid"
					sh "sleep 20"
					action()
				}
    	} else {
				action()
			}
		}
}

def testCore(key, device) {
    test(key, device, 'CoreTests')
}

def testMobileEngage(key, device) {
    test(key, device, 'MobileEngageTests')
}

def testPredict(key, device) {
    test(key, device, 'PredictTests')
}

def testEmarsysSDK(key, device) {
    test(key, device, 'EmarsysSDKTests')
}

def createSimulator(deviceType, runtimeType) {
	def name = UUID.randomUUID().toString()
	return sh(returnStdout: true, script: "xcrun simctl create $name $deviceType $runtimeType").trim()
}

def killSimulators(simulators){
	for (simulator in simulators) {
			simulator.each { key, device ->
				sh "xcrun simctl shutdown $device.udid || true"
				sh "xcrun simctl erase $device.udid"
			}
	}
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

def runActionOnAllDevices(Closure action) {
	def realDevices = getTestDevices()
	def simulators = createTestSimulators()
	def devices = realDevices + simulators
	doParallel(devices, action)
	killSimulators(simulators)
}

def getTestDevices() {
	return [
		[iPad_Pro: new Device(env.IPAD_PRO, 'iOS')]
	]
}

def createTestSimulators() {
	return [
		[Simulator93: new Device(createSimulator('com.apple.CoreSimulator.SimDeviceType.iPhone-6s', 'com.apple.CoreSimulator.SimRuntime.iOS-9-3'), 'iOS Simulator')],
		[Simulator103: new Device(createSimulator('com.apple.CoreSimulator.SimDeviceType.iPhone-6s', 'com.apple.CoreSimulator.SimRuntime.iOS-10-3'), 'iOS Simulator')]
	]
}

node('master') {
    withSlack channel: 'jenkins', {
        stage('Init') {
            deleteDir()
            printBuildToolVersions()
        }
        stage('Git Clone') {
					runActionOnAllDevices(this.&clone)
        }
        stage('Pod install') {
            sh 'eval $(ssh-agent) && ssh-add ~/.ssh/ios-pod-private-repo'
            runActionOnAllDevices(this.&podi)
        }
        stage('Build') {
            runActionOnAllDevices(this.&build)
        }
        stage('Pod lint') {
        	sh "cd iPad_Pro/ios-emarsys-sdk && pod lib lint EmarsysSDK.podspec --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
        }
        stage('Pod lint NotificationService') {
            sh "cd iPad_Pro/ios-emarsys-sdk && pod lib lint EmarsysNotificationService.podspec --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
        }
        stage('Test Core') {
        	runActionOnAllDevices(this.&testCore)
        }
        stage('Test MobileEngage') {
        	runActionOnAllDevices(this.&testMobileEngage)
        }
        stage('Test Predict') {
        	runActionOnAllDevices(this.&testPredict)
        }
        stage('Test EmarsysSDK') {
        	runActionOnAllDevices(this.&testEmarsysSDK)
        }
        stage('Deploy to private pod repo') {
            sh "cd iPad_Pro/ios-emarsys-sdk && ./private-release.sh ${env.BUILD_NUMBER}.0.0"
        }
        stage('Deploy NotificationService to private pod repo') {
            sh "cd iPad_Pro/ios-emarsys-sdk && ./private-NSRelease.sh ${env.BUILD_NUMBER}.0.0"
        }
        stage('Finish') {
            echo "That is just pure awesome!"
        }
    }
}
