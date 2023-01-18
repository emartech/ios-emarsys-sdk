//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct ContactClient {
    
    let networkClient: NetworkClient
    let defaultValues: DefaultValues
    let sdkContext: SdkContext
    var sessionHandler: SessionHandler
    
    func linkContact(contactFieldId: Int, contactFieldValue: String? = nil, openIdToken: String? = nil) async throws {
        guard let contactLinkingUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(sdkContext.config?.applicationCode)/client/contact")) else {
            return //TODO: error handling what to do
        }
        if !(contactFieldValue == nil || openIdToken == nil) {
            throw Errors.preconditionFailed("preconditionFailed".localized(with: "contactFieldValue: \(String(describing: contactFieldValue)) or openIdToken: \(String(describing: openIdToken)) must not be nil"))
        }
        var body = [String: String]()
        body["contactFieldId"] = "\(contactFieldId)"
        body["contactFieldValue"] = contactFieldValue
        body["openIdToken"] = openIdToken
        var url = contactLinkingUrl
        url.add(queryParameters: ["anonymous": "\(false)"])
        
        let request = URLRequest.create(url: url, method: .POST, body: body.toData())
        await sendContactRequest(request: request)
    }
    
    func unlinkContact() async {
        guard let contactLinkingUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(sdkContext.config?.applicationCode)/client/contact")) else {
            return //TODO: error handling what to do
        }
        let body = [String: String]()
        var url = contactLinkingUrl
        url.add(queryParameters: ["anonymous": "\(true)"])
        let request = URLRequest.create(url: url, method: .POST, body: body.toData())
        await sendContactRequest(request: request)
    }
    
    private func sendContactRequest(request: URLRequest) async {
        let result: (Data, HTTPURLResponse) = try! await networkClient.send(request: request)
//        switch result {
//        case .success(let response):
//            if let body = response.data.toDict() as? [String: String] {
//                self.sessionHandler.contactToken = body["contactToken"]
//                self.sessionHandler.refreshToken = body["refreshToken"]
//            }
//        case .failure(let error):
//            // TODO: error handling
//            print("error: \(error)")
//        }
    }
    
}
