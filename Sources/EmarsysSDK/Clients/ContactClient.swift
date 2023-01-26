import Foundation

protocol ContactClient {
    func linkContact(contactFieldId: Int, contactFieldValue: String?, openIdToken: String?) async throws
    func unlinkContact() async
}