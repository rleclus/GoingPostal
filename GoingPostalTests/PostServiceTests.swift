//
//  PostServiceTests.swift
//  GoingPostalTests
//
//  Created by Robert le Clus on 2024/05/18.
//

import XCTest
import CoreData
@testable import GoingPostal

class PostServiceTests: XCTestCase {
    
    var postService: PostService!
    var mockPersistentContainer: NSPersistentContainer!
    
    override func setUpWithError() throws {
        super.setUp()
        let coreDataStack = CoreDataStack(inMemory: true)
        postService = PostService(coreDataStack: coreDataStack)
        mockPersistentContainer = coreDataStack.persistentContainer
    }
    
    override func tearDownWithError() throws {
        postService = nil
        mockPersistentContainer = nil
        super.tearDown()
    }
    
    func testAddPost() {
        let result = postService.addPost(userId: 1, id: 1, title: "Test Title", body: "Test Body")
        XCTAssertTrue(result, "The post should be added successfully")
        
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        do {
            let posts = try mockPersistentContainer.viewContext.fetch(fetchRequest)
            XCTAssertEqual(posts.count, 1, "There should be one post in the context")
            XCTAssertEqual(posts.first?.title, "Test Title", "The post title should match")
        } catch {
            XCTFail("Fetching posts failed: \(error)")
        }
    }
    
    func testAddDuplicatePost() {
        let firstresult = postService.addPost(userId: 1, id: 1, title: "Duplicate Title", body: "Test Body")
        XCTAssertTrue(firstresult, "Item should be added correctly")
        let result = postService.addPost(userId: 1, id: 2, title: "Duplicate Title", body: "Another Test Body")
        XCTAssertFalse(result, "The duplicate post should not be added")
        XCTAssertEqual(postService.errorMessage, "Duplicate Entry. Title already exists.", "The error message should be set for duplicate entry")
        
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        do {
            let posts = try mockPersistentContainer.viewContext.fetch(fetchRequest)
            XCTAssertEqual(posts.count, 1, "There should be only one post in the context")
        } catch {
            XCTFail("Fetching posts failed: \(error)")
        }
    }
    
    func testDeletePost() {
        // Add a post to delete
        let expectation = XCTestExpectation(description: "Delete post")
        let result = postService.addPost(userId: 1, id: 1, title: "Title to Delete", body: "Test Body")
        XCTAssertTrue(result, "This post should have been added")

        // Trigger the deletion operation
        postService.deletePost(withTitle: "Title to Delete")
        
        // Wait for a short period to ensure the deletion operation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Assert the result after waiting
            let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
            do {
                let posts = try self.mockPersistentContainer.viewContext.fetch(fetchRequest)
                XCTAssertEqual(posts.count, 0, "There should be no posts in the context after deletion")
                expectation.fulfill()
            } catch {
                XCTFail("Fetching posts failed: \(error)")
            }
        }
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 5.0)
    }
    func testFetchPosts() {
        _ = postService.addPost(userId: 1, id: 1, title: "Title A", body: "Test Body A")
        _ = postService.addPost(userId: 2, id: 2, title: "Title B", body: "Test Body B")
        
        postService.fetchStoredPosts()
        XCTAssertEqual(postService.posts.count, 2, "There should be two posts in the fetched array")
        
        let titles = postService.posts.map { $0.title }
        XCTAssertEqual(titles, ["Title A", "Title B"], "The posts should be fetched and sorted by title")
    }
}

