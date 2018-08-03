import groovy.transform.TupleConstructor

@Library('general-pipeline') _

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
        sh "mkdir /tmp/$uuid"
        sh "cd $device.udid/ios-emarsys-sdk && xcodebuild -workspace ./EmarsysSDK.xcworkspace -scheme EmarsysSDK -configuration debug -derivedDataPath $uuid"
    }
}

def test(device, scheme) {
	lock(device.udid) {
        def uuid = UUID.randomUUID().toString()
        try {
            retry(3) {
                sh "cd $device.udid/ios-emarsys-sdk && scan --scheme $scheme -d 'platform=$device.platform,id=$device.udid' --derived_data_path $uuid -o test_output/unit/ "
            }
        } catch (e) {
            currentBuild.result = 'FAILURE'
            throw e
        } finally {
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

@TupleConstructor()
class Device {
	def udid
	def platform
}

def doParallel(Closure action) {
    def devices = [
        [iPhone_5S: new Device(env.IPHONE_5S, 'iOS')],
        [iPhone_6S: new Device(env.IPHONE_6S, 'iOS')],
        [iPad_Pro: new Device(env.IPAD_PRO, 'iOS')],
        [iOS_9_3_Simulator: new Device(env.IOS93SIMULATOR, 'iOS Simulator')]
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
        stage('Start') {
            deleteDir()
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
        	sh "cd $env.IPAD_PRO/ios-emarsys-sdk && pod lib lint --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
        }
        stage('Test Core') {
        	doParallel(this.&testCore)
        }
        stage('Test MobileEngage') {
        	doParallel(this.&testMobileEngage)
        }
        stage('Deploy to private pod repo') {
            sh "cd $env.IPAD_PRO/ios-emarsys-sdk && ./private-release.sh ${env.BUILD_NUMBER}.0.0"
        }
        stage('Finish') {
            echo "That is just pure awesome!"
        }
    }
}
