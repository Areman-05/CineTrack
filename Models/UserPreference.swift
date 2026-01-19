//
//  UserPreference.swift
//  CineTrack
//
//  Modelo para los datos creados por el usuario
//

import Foundation

struct UserPreference: Codable {
    var isFavorite: Bool
    var personalNote: String
    
    init(isFavorite: Bool = false, personalNote: String = "") {
        self.isFavorite = isFavorite
        self.personalNote = personalNote
    }
}
