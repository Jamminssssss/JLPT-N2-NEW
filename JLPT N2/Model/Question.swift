//
//  Question.swift
//  JLPT N2
//
//  Created by jaemin park on 2023/03/22.
//

import SwiftUI

struct Question: Identifiable, Codable{
    var id: UUID = .init()
    var question: String
    var options: [String]
    var answer: String
    
    var tappedAnswer: String =  ""
    
    enum CodingKeys: CodingKey {
        case question
        case options
        case answer
    }
}
