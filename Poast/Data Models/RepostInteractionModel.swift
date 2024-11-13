//
//  RepostInteractionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/12/24.
//

import SwiftData

@Model
final class RepostInteractionModel {
    @Attribute(.unique)
    var postUri: String
    var interaction: RepostModel

    init(postUri: String, interaction: RepostModel) {
        self.postUri = postUri
        self.interaction = interaction
    }
}
