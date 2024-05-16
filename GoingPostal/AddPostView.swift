//
//  AddPostView.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//

import SwiftUI

struct AddPostView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var postService: PostService
    @State private var postTitle = ""
    @State private var postBody = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter Title", text: $postTitle)
                }
                
                Section(header: Text("Body")) {
                    TextEditor(text: $postBody)
                        .frame(height: 150)
                }
            }
            .navigationBarTitle("Add Post")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    postService.addPost(userId: 1, id: Int(Date().timeIntervalSince1970), title: postTitle, body: postBody)
                    isPresented = false
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


