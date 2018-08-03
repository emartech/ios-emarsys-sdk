@Library('general-pipeline') _

def clone(udid) {
    checkout changelog: true, poll: true, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "$udid/ios-emarsys-sdk"]], submoduleCfg: [], userRemoteConfigs: [[url: 'git@github.com:emartech/ios-emarsys-sdk.git']]]
}

def podi(udid) {
    lock("pod") {
        sh "pod repo update"
        sh "cd $udid/ios-emarsys-sdk && pod install --verbose"
    }
}

def podiLinti(udid) {
    lock(udid) {
        sh "cd $udid/ios-emarsys-sdk && pod lib lint --allow-warnings --sources=git@github.com:emartech/pod-private.git,master"
    }
}

def buildAndTest(platform, udid) {
    lock(udid) {
        def uuid = UUID.randomUUID().toString()
        try {
            sh "mkdir /tmp/$uuid"
            retry(3) {
                sh "cd $udid/ios-emarsys-sdk && scan --scheme Tests -d 'platform=$platform,id=$udid' --derived_data_path $uuid -o test_output/unit/"
            }
        } catch (e) {
            currentBuild.result = 'FAILURE'
            throw e
        } finally {
            junit "$udid/ios-emarsys-sdk/test_output/unit/*.junit"
            archiveArtifacts "$udid/ios-emarsys-sdk/test_output/unit/*"
        }
    }
}

def doParallel(Closure action) {
    println '2'
    def devices = [
        [iPhone_5S: env.IPHONE_5S],
        [iPhone_6S: env.IPHONE_6S],
        [iPad_Pro: env.IPAD_PRO],
        [iOS_9_3_Simulator: env.IOS93SIMULATOR]
    ]
    println '3'
    def parallelActions = [:]
    println '4'
    for (device in devices) {
        device.each { key, value ->
            parallelActions[key] = {
                println '7'
                action(value)
            }
        }
        println '6'
    }
    parallelActions['failFast'] = false
    println '8'
    parallel parallelActions
    println '9'
}

node('master') {
    withSlack channel: 'jenkins', {
        stage('Start') {
            deleteDir()
        }
        stage('Git Clone') {
            println '1'
            doParallel(this.&clone)
        }
        stage('Pod install') {
            sh 'eval $(ssh-agent) && ssh-add ~/.ssh/ios-pod-private-repo'
            doParallel(this.&podi)
        }
        stage('Pod lint') {
            doParallel(this.&podiLinti)
        }
        stage('Build and Test') {
            parallel iPhone_5S: {
                buildAndTest 'iOS', env.IPHONE_5S
            }, iPhone_6S: {
                // echo "Skipped, please trust mac mini when you can open the rack."
                buildAndTest 'iOS', env.IPHONE_6S
            }, iPad_Pro: {
                buildAndTest 'iOS', env.IPAD_PRO
            }, iOS_9_3_Simulator: {
                buildAndTest 'iOS Simulator', env.IOS93SIMULATOR
            }, failFast: false
        }
        stage('Deploy to private pod repo') {
            sh "cd $env.IPAD_PRO/ios-emarsys-sdk && ./private-release.sh ${env.BUILD_NUMBER}.0.0"
        }
        stage('Finish') {
            echo "That is just pure awesome!"
        }
    }
}
