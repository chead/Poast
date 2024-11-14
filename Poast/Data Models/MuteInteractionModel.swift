//
//  MuteInteractionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/26/24.
//

import SwiftData

@Model
final class MuteInteractionModel {
    @Attribute(.unique)
    var postUri: String
    var interaction: MuteModel

    init(postUri: String, interaction: MuteModel) {
        self.postUri = postUri
        self.interaction = interaction
    }
}
