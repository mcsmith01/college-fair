//
//  Encryption.swift
//  College Fair
//
//  Created by Chase Smith on 5/12/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
//import CryptoSwift

class Encryption {
	
	static let key = "13768f519774af77941a62036223137a"
	static let iv =  "5c36b56beb5518da"
	
	class func aesEncrypt(_ string: String, key: String, iv: String) throws -> String {
		return string
//		let data = string.utf8
//		let aes = try AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7())
//		let enc = try aes.encrypt(Array(data))
//		let encData = NSData(bytes: enc, length: Int(enc.count))
//		let base64String: String = encData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//		let result = String(base64String)
//		return result!
	}
	
	class func aesDecrypt(_ cipher: String, key: String, iv: String) throws -> String {
		return cipher
//		let data = NSData(base64Encoded: cipher, options: NSData.Base64DecodingOptions(rawValue: 0))
//		let dec = try (data! as Data).decrypt(cipher: AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()))
//		let result = NSString(data: dec, encoding: String.Encoding.utf8.rawValue)
//		return String(result!)
	}

}

struct KeychainAccess {
	
	enum KeychainError: Error {
		case noPassword
		case unexpectedPasswordData
		case unhandledError(status: OSStatus)
	}
	
	static func savePassword(_ password: String, forAccount account: String) throws {
		let encodedPassword = password.data(using: .utf8)!
		let status: OSStatus
		if try readPassword(forAccount: account) == nil {
			// Create new account
			var query = buildQuery(forAccount: account)
			query[kSecValueData as String] = encodedPassword as AnyObject?
			status = SecItemAdd(query as CFDictionary, nil)
		} else {
			// Update password
			var updateAttributes = [String: AnyObject]()
			updateAttributes[kSecValueData as String] = encodedPassword as AnyObject?
			let query = buildQuery(forAccount: account)
			status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
		}
		if status != noErr {
			throw KeychainError.unhandledError(status: status)
		}
	}
	
	static func readPassword(forAccount account: String) throws -> String? {
		var query = buildQuery(forAccount: account)
		query[kSecMatchLimit as String] = kSecMatchLimitOne
		query[kSecReturnAttributes as String] = kCFBooleanTrue
		query[kSecReturnData as String] = kCFBooleanTrue
		var queryResults: AnyObject?
		let status = withUnsafeMutablePointer(to: &queryResults) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		if status == errSecItemNotFound {
			return nil
		} else if status != noErr {
			throw KeychainError.unhandledError(status: status)
		}
		guard let passwordDict = queryResults as? [String: AnyObject], let passwordData = passwordDict[kSecValueData as String] as? Data, let password = String(data: passwordData, encoding: .utf8)
			else {
				throw KeychainError.unexpectedPasswordData
		}
		return password
	}
	
	static func buildQuery(forAccount account: String) -> [String: AnyObject] {
		var query = [String: AnyObject]()
		query[kSecClass as String] = kSecClassGenericPassword
		query[kSecAttrAccount as String] = account as AnyObject?
		return query
	}
}
