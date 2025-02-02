module my_addr::social {
    use std::signer;
    use my_addr::profiles;
    use my_addr::posts;

    // Entry function to like a post
    public entry fun like_post(
        liker: &signer, // Ensure this is a &signer
        target: address,
        post_id: u64
    ) {
        posts::like_post(liker, target, post_id);
    }

    // Entry function to follow a user
    public entry fun follow_user(
        follower: &signer, // Ensure this is a &signer
        target: address
    ) {
        profiles::add_follower(signer::address_of(follower), target);
    }
}