module my_addr::profiles {
    use std::string::String;
    use std::vector;
    use std::signer;

    // Constants are internal to the module
    const E_PROFILE_EXISTS: u64 = 1;
    const E_PROFILE_NOT_FOUND: u64 = 2;

    struct Profile has key ,copy,drop{
        username: String,
        bio: String,
        followers: vector<address>,
        following: vector<address>
    }

    // Public getter for E_PROFILE_EXISTS
    public fun get_e_profile_exists(): u64 {
        E_PROFILE_EXISTS
    }

    // Public getter for E_PROFILE_NOT_FOUND
    public fun get_e_profile_not_found(): u64 {
        E_PROFILE_NOT_FOUND
    }

    // Internal helper (returns bool)
    public fun internal_profile_exists(addr: address): bool {
        exists<Profile>(addr)
    }

    // Public view function (returns vector<bool> for Aptos ABI)
    public fun profile_exists_view(addr: address): vector<bool> {
        vector[internal_profile_exists(addr)]
    }

     // Get username
    public fun get_username(addr: address): vector<String> acquires Profile {
        assert!(exists<Profile>(addr), E_PROFILE_NOT_FOUND);
        let profile = borrow_global<Profile>(addr);
        vector[profile.username]
    }

    // Get bio
    public fun get_bio(addr: address): vector<String> acquires Profile {
        assert!(exists<Profile>(addr), E_PROFILE_NOT_FOUND);
        let profile = borrow_global<Profile>(addr);
        vector[profile.bio]
    }
    
    // Get followers list
    public fun get_followers(addr: address): vector<address> acquires Profile {
        assert!(exists<Profile>(addr), E_PROFILE_NOT_FOUND);
        let profile = borrow_global<Profile>(addr);
        profile.followers
    }

    // Get following list
    public fun get_following(addr: address): vector<address> acquires Profile {
        assert!(exists<Profile>(addr), E_PROFILE_NOT_FOUND);
        let profile = borrow_global<Profile>(addr);
        profile.following
    }

    // Get followers count
    public fun get_followers_count(addr: address): vector<u64> acquires Profile {
        assert!(exists<Profile>(addr), E_PROFILE_NOT_FOUND);
        let profile = borrow_global<Profile>(addr);
        vector[vector::length(&profile.followers)]
    }

    // Get following count
    public fun get_following_count(addr: address): vector<u64> acquires Profile {
        assert!(exists<Profile>(addr), E_PROFILE_NOT_FOUND);
        let profile = borrow_global<Profile>(addr);
        vector[vector::length(&profile.following)]
    }

    // Entry function to create a profile
    public entry fun create_profile(
        user: &signer,
        username: String,
        bio: String
    ) {
        let addr = signer::address_of(user);
        assert!(!internal_profile_exists(addr), E_PROFILE_EXISTS);

        move_to(user, Profile {
            username,
            bio,
            followers: vector::empty(),
            following: vector::empty()
        });
    }
    public fun profile_exists(addr: address): bool {
        internal_profile_exists(addr)
    }

    // Public function to retrieve a profile
    public fun get_profile(addr: address): Profile acquires Profile {
        assert!(profile_exists(addr), E_PROFILE_NOT_FOUND);
        *borrow_global<Profile>(addr) // Return a copy of the Profile
    }

    // Public function to add a follower
    public fun add_follower(follower: address, target: address) acquires Profile {
        assert!(profile_exists(follower), E_PROFILE_NOT_FOUND);
        assert!(profile_exists(target), E_PROFILE_NOT_FOUND);

        // Update the follower's profile first
        {
            let follower_profile = borrow_global_mut<Profile>(follower);
            if (!vector::contains(&follower_profile.following, &target)) {
                vector::push_back(&mut follower_profile.following, target);
            }
        }; // End of scope for `follower_profile`

        // Update the target's profile next
        {
            let target_profile = borrow_global_mut<Profile>(target);
            if (!vector::contains(&target_profile.followers, &follower)) {
                vector::push_back(&mut target_profile.followers, follower);
            }
        } // End of scope for `target_profile`
    }
    public entry fun delete_profile(user: &signer) acquires Profile {
    let addr = signer::address_of(user);
    assert!(internal_profile_exists(addr), E_PROFILE_NOT_FOUND);
    move_from<Profile>(addr);
}
}
