//
//  PoastPostRepostInteractionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/12/24.
//

import SwiftData

@Model
final class PoastPostRepostInteractionModel {
    @Attribute(.unique)
    var postUri: String
    var interaction: PoastPostRepostModel

    init(postUri: String, interaction: PoastPostRepostModel) {
        self.postUri = postUri
        self.interaction = interaction
    }
}
