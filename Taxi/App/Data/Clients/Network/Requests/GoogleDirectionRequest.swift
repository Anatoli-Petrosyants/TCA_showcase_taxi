//
//  GoogleDirectionRequest.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 30.10.23.
//

struct GoogleDirectionRequest: Encodable {
    let key: String
    let origin: String
    let destination: String
    let mode: String
    let region: String
}
