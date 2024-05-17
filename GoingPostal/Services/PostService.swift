//
//  PostService.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//

import Foundation
import CoreData

class PostService: ObservableObject {
    static let shared = PostService()
    
    private init() {
        fetchStoredPosts()
    }
    
    @Published var posts: [Post] = []
    @Published var errorMessage = "An error has occurred!"

    func fetchPostsAndUpdateCoreData() async {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let postsResponse = try JSONDecoder().decode([PostResponse].self, from: data)
            
            // Perform Core Data operations on a background context
            let context = CoreDataStack.shared.backgroundContext()
            await context.perform {
                self.updateCoreData(with: postsResponse, context: context)
            }
        } catch {
            print("Error fetching posts: \(error.localizedDescription)")
        }
    }
    
    private func updateCoreData(with postsResponse: [PostResponse], context: NSManagedObjectContext) {
        for postResponse in postsResponse {
            let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", postResponse.id)
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.isEmpty {
                    // This post does not exist in Core Data, so create a new one
                    let newPost = Post(context: context)
                    newPost.userID = Int32(postResponse.userId)
                    newPost.id = Int32(postResponse.id)
                    newPost.title = postResponse.title
                    newPost.body = postResponse.body
                }
            } catch {
                print("Error fetching post: \(error.localizedDescription)")
            }
        }
        
        // Save changes to Core Data
        do {
            try context.save()
            // Update the published posts array on the main thread to notify the view
            DispatchQueue.main.async {
                self.fetchStoredPosts()
            }
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }

    private func fetchStoredPosts() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        
        do {
            self.posts = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching posts from Core Data: \(error.localizedDescription)")
        }
    }
    
    func addPost(userId: Int, id: Int, title: String, body: String) -> Bool {
        // Check for duplicate titles before adding a new post
        guard !posts.contains(where: { $0.title?.caseInsensitiveCompare(title) == .orderedSame }) else {
            errorMessage = "Duplicate Entry. Title already exists."
            return false
        }
        
        let context = CoreDataStack.shared.context
        
        context.performAndWait {
            let newPost = Post(context: context)
            newPost.userID = Int32(userId)
            newPost.id = Int32(id)
            newPost.title = title
            newPost.body = body
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.fetchStoredPosts()
                }
            } catch {
                print("Error saving new post: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    func deletePost(withTitle title: String) {
        let context = CoreDataStack.shared.context
        
        context.perform {
            let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)
            
            do {
                let postsToDelete = try context.fetch(fetchRequest)
                for post in postsToDelete {
                    context.delete(post)
                }
                try context.save()
                DispatchQueue.main.async {
                    self.fetchStoredPosts()
                }
            } catch {
                print("Error deleting post: \(error.localizedDescription)")
            }
        }
    }
}

// Define a struct to represent the JSON response
struct PostResponse: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
