module my_addr::posts {
    use std::string::String;
    use std::vector;
    use std::signer;
    use my_addr::profiles;
    use my_addr::events;

    // Constants are internal to the module
    const E_POST_NOT_FOUND: u64 = 3;

    struct Post has store {
        id: u64,
        content: String,
        likes: vector<address>
    }

    struct UserPosts has key {
        posts: vector<Post>
    }

    // Public getter for E_POST_NOT_FOUND
    public fun get_e_post_not_found(): u64 {
        E_POST_NOT_FOUND
    }

    // Function to check if a user has posts
    public fun user_posts_exist(addr: address): bool {
        exists<UserPosts>(addr)
    }

    // Get total posts count for a user
    public fun get_post_count(addr: address): vector<u64> acquires UserPosts {
        assert!(exists<UserPosts>(addr), profiles::get_e_profile_not_found());
        let user_posts = borrow_global<UserPosts>(addr);
        vector[vector::length(&user_posts.posts)]
    }

    // Get post content by ID
    public fun get_post_content(
        addr: address,
        post_id: u64
    ): vector<String> acquires UserPosts {
        assert!(exists<UserPosts>(addr), profiles::get_e_profile_not_found());
        let user_posts = borrow_global<UserPosts>(addr);
        assert!(post_id < vector::length(&user_posts.posts), E_POST_NOT_FOUND);
        let post = vector::borrow(&user_posts.posts, post_id);
        vector[post.content]
    }

    // Get likes count for a post
    public fun get_post_likes_count(
        addr: address,
        post_id: u64
    ): vector<u64> acquires UserPosts {
        assert!(exists<UserPosts>(addr), profiles::get_e_profile_not_found());
        let user_posts = borrow_global<UserPosts>(addr);
        assert!(post_id < vector::length(&user_posts.posts), E_POST_NOT_FOUND);
        let post = vector::borrow(&user_posts.posts, post_id);
        vector[vector::length(&post.likes)]
    }

    // Get list of addresses who liked a post
    public fun get_post_likes(
        addr: address,
        post_id: u64
    ): vector<address> acquires UserPosts {
        assert!(exists<UserPosts>(addr), profiles::get_e_profile_not_found());
        let user_posts = borrow_global<UserPosts>(addr);
        assert!(post_id < vector::length(&user_posts.posts), E_POST_NOT_FOUND);
        let post = vector::borrow(&user_posts.posts, post_id);
        post.likes
    }

    // Get all posts (returns vector of contents)
    public fun get_all_posts(addr: address): vector<String> acquires UserPosts {
        assert!(exists<UserPosts>(addr),profiles::get_e_profile_not_found());
        let user_posts = borrow_global<UserPosts>(addr);
        let posts = &user_posts.posts;
        let result = vector::empty<String>();
        let i = 0;
        while (i < vector::length(posts)) {
            let post = vector::borrow(posts, i);
            vector::push_back(&mut result, post.content);
            i = i + 1;
        };
        result
    }

    // Entry function to create a post
    public entry fun create_post(
        user: &signer,
        content: String
    ) acquires UserPosts {
        let addr = signer::address_of(user);
        assert!(
            profiles::internal_profile_exists(addr),
            profiles::get_e_profile_not_found()
        );

        if (!user_posts_exist(addr)) {
            move_to(user, UserPosts {
                posts: vector::empty<Post>()
            });
        };

        let user_posts = borrow_global_mut<UserPosts>(addr);

        // Calculate the length of the vector before creating a mutable borrow
        let post_id = vector::length(&user_posts.posts);

        // Create a mutable borrow after calculating the length
        let posts_ref = &mut user_posts.posts;

        vector::push_back(posts_ref, Post {
            id: post_id,
            content,
            likes: vector::empty<address>()
        });

        // Emit an event for the new post
        events::emit_create_post(user, content);
    }

    // Public function to like a post
    public fun like_post(user: &signer, target: address, post_id: u64) acquires UserPosts {
        let liker_addr = signer::address_of(user);
        assert!(profiles::internal_profile_exists(liker_addr), profiles::get_e_profile_not_found()); // Check liker's profile
        assert!(
            profiles::internal_profile_exists(target), 
            profiles::get_e_profile_not_found()
        );
        assert!(user_posts_exist(target), E_POST_NOT_FOUND); // Check target's posts

        let user_posts = borrow_global_mut<UserPosts>(target);
        let posts_ref = &mut user_posts.posts; // Mutable reference
        let post = vector::borrow_mut(posts_ref, post_id);

        if (!vector::contains(&post.likes, &liker_addr)) {
            vector::push_back(&mut post.likes, liker_addr);

            // Emit an event for the like
            events::emit_like_event(target, liker_addr);
        }
    }
}
