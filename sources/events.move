module my_addr::events {
    use aptos_framework::event;
    use std::string::String;
    use std::signer;

    // Define the CreatePostEvent struct with the #[event] attribute
    #[event]
    struct CreatePostEvent has drop, store {
        author: address,
        content: String
    }

    // Define the LikeEvent struct with the #[event] attribute
    #[event]
    struct LikeEvent has drop, store {
        post_owner: address,
        liker: address
    }

    // Function to emit a CreatePostEvent
    public fun emit_create_post(user: &signer, content: String) {
        let author = signer::address_of(user);
        event::emit(CreatePostEvent { author, content });
    }

    // Function to emit a LikeEvent
    public fun emit_like_event(post_owner: address, liker: address) {
        event::emit(LikeEvent { post_owner, liker });
    }
}