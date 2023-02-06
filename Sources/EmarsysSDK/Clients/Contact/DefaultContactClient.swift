//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct DefaultContactClient: ContactClient {

    let emarsysClient: NetworkClient
    let defaultValues: DefaultValues
    let sdkContext: SdkContext
    var sessionContext: SessionContext
    let sdkLogger: SDKLogger

    func linkContact(contactFieldId: Int, contactFieldValue: String? = nil, openIdToken: String? = nil) async throws {
        guard let applicationCode = sdkContext.config?.applicationCode else {
            throw Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        }
        guard let contactBaseUrl = URL(string: defaultValues.clientServiceBaseUrl) else {
            throw Errors.preconditionFailed(message: "Url cannot be created for linkContactRequest!")
        }
        let contactLinkingUrl = contactBaseUrl.appending(path: "/v3/apps/\(applicationCode)/client/contact")
        
        if contactFieldValue == nil && openIdToken == nil {
            throw Errors.preconditionFailed(message: "Either contactFieldValue or openIdToken must not be nil")
        }

        var body = [String: String]()
        body["contactFieldId"] = "\(contactFieldId)"
        body["contactFieldValue"] = contactFieldValue
        body["openIdToken"] = openIdToken
        var url = contactLinkingUrl
        url.add(queryParameters: ["anonymous": "\(false)"])

        let request = URLRequest.create(url: url, method: .POST, body: body.toData())
        try await sendContactRequest(request: request)
    }

    func unlinkContact() async throws {
        guard let applicationCode = sdkContext.config?.applicationCode else {
            throw Errors.preconditionFailed(message: "ApplicationCode should not be nil!")
        }
        guard let contactBaseUrl = URL(string: defaultValues.clientServiceBaseUrl) else {
            throw Errors.preconditionFailed(message: "Url cannot be created for linkContactRequest!")
        }
        let contactLinkingUrl = contactBaseUrl.appending(path: "/v3/apps/\(applicationCode)/client/contact")
        
        let body = [String: String]()
        var url = contactLinkingUrl
        url.add(queryParameters: ["anonymous": "\(true)"])
        let request = URLRequest.create(url: url, method: .POST, body: body.toData())
        try await sendContactRequest(request: request)
    }

    private func sendContactRequest(request: URLRequest) async throws {
        do {
            let response: (ContactResponse, HTTPURLResponse) = try await emarsysClient.send(request: request)
            sessionContext.contactToken = response.0.contactToken
            sessionContext.refreshToken = response.0.refreshToken
        } catch Errors.NetworkingError.failedRequest(let response){
            sessionContext.contactToken = nil
            sessionContext.refreshToken = nil
            
            let logEntry = LogEntry(topic: "default-contact-client",
                                    data: [
                                        "response": response
                                    ])
            sdkLogger.log(logEntry: logEntry, level: .debug)
            throw Errors.UserFacingRequestError.contactRequestFailed(url: String(describing: request.url))
        }
    }

}
