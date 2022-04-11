module launch-cloud-image 1.0;

require {
	class dir {
        open
        search
        getattr

        add_name
        remove_name
        reparent
        rmdir
        

        append
        create
        execute
        
        ioctl
        link
        lock
        mounton
        quotaon
        
        read
        relabelfrom
        relabelto
        rename
        setattr
        swapon
        unlink
        write
    };

	class file {
        open

        append
        create
        execute
        getattr
        ioctl
        link
        lock
        mounton
        quotaon
        read
        relabelfrom
        relabelto
        rename
        setattr
        swapon
        unlink
        write 
    };

    class lnk_file { 
        open

        append
        create
        execute
        getattr
        ioctl
        link
        lock
        mounton
        quotaon
        read
        relabelfrom
        relabelto
        rename
        setattr
        swapon
        unlink
        write 
    };

    attribute user_home_type;
    attribute virt_domain;

    type user_home_t;
    type user_home_dir_t;
    type cache_home_t;
    type ssh_home_t;
}

#============= svirt_t ==============

# Allow read-only access to the entire home directory structure
allow virt_domain user_home_type:dir { open search read getattr };
allow virt_domain user_home_type:file { open read getattr };
allow virt_domain user_home_type:lnk_file { open read getattr };

# Allow write access to non-specifically categorized items
allow virt_domain user_home_dir_t:dir { 
    add_name append create link lock unlink rename setattr rmdir write 
    remove_name reparent read getattr search open
};

allow virt_domain user_home_dir_t:file { 
    append create link lock unlink rename setattr write getattr read open
};

allow virt_domain user_home_dir_t:lnk_file { 
    append create link lock unlink rename setattr write getattr read open
};

allow virt_domain user_home_t:dir { 
    add_name append create link lock unlink rename setattr rmdir write 
    remove_name reparent 
};

allow virt_domain user_home_t:file { 
    append create link lock unlink rename setattr write 
};

allow virt_domain user_home_t:lnk_file { 
    append create link lock unlink rename setattr write getattr read open
};

# Allow write access to .cache
allow virt_domain cache_home_t:dir { 
    add_name append create link lock unlink rename setattr rmdir write 
    remove_name reparent read getattr search open
};

allow virt_domain cache_home_t:file { 
    append create link lock unlink rename setattr write getattr read open
};


allow virt_domain cache_home_t:lnk_file { 
    append create link lock unlink rename setattr write getattr read open
};

# Allow write access to the ssh_home_t directory only
allow virt_domain ssh_home_t:dir { 
    add_name append create link lock unlink rename setattr rmdir write 
    remove_name reparent 
};

allow virt_domain ssh_home_t:file { 
    append create link lock unlink rename setattr write getattr read open
};

