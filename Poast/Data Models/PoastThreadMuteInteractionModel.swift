//
//  PoastPostMuteInteractionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/26/24.
//

import SwiftData

@Model
final class PoastThreadMuteInteractionModel {
    @Attribute(.unique)
    var postUri: String
    var interaction: PoastThreadMuteModel

    init(postUri: String, interaction: PoastThreadMuteModel) {
        self.postUri = postUri
        self.interaction = interaction
    }
}
