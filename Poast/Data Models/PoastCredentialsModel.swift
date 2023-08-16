//
//  PoastCredentialsModel.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

import Foundation

struct PoastCredentialsModel: Hashable, Codable {
    let accessToken: String
    let refreshToken: String
}
