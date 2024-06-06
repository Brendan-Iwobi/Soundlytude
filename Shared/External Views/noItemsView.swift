//
//  noItemsView.swift
//  Soundlytude
//
//  Created by DJ bon26 on 10/22/22.
//

import SwiftUI

struct noItemsView: View {
    var title: String = "No uploads yet"
    var message: String = "Uploads by this user will appear herehis user will appear herehis user will appear here"
    var body: some View {
        VStack(spacing: 20){
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .padding(.vertical)
            .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
    }
}

struct tapToRetryView: View {
    var title: String = "Couldn't fetch data"
    var message: String = "Tap to retry"
    var body: some View {
        VStack(spacing: 20){
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            HStack{
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(Color.gray)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
            }
        }.frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .padding(.vertical)
            .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
    }
}

struct noItemsView_Previews: PreviewProvider {
    static var previews: some View {
        tapToRetryView()
    }
}
