//
//  CredentialsModel.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

struct CredentialsModel: Hashable, Codable {
    let accessToken: String
    let refreshToken: String
}
