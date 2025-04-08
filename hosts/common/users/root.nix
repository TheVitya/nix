{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.root = {
    # Public SSH key to allow login without a password (useful for headless systems)
    # Enables passwordless SSH login for this user
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpqUlEzSQKT9z7IM1QNZIogzQQecrFGkUOxltJIfGqGoRrMTPqTkAidoLM9iw9Xsb7JAx2PUk0pVS4SXKO7cNJjv/Ty3eldqJKtHOd6rZiDnRvMunYzR7MjExg/BscR+VUyY0V+dDOC1ljJMAjP/CEXug21OEv9l1gNtxOx+NCJqDJNpkcCweoyBheVuzbOF6pwSWwEa3OYi7llc+g2/Xt89Sx4bfeRavN5lmVyJrR9PXmrE2hSLJP3XxVPhpIkiDNff4aODLZQsaXIKn7J8j2tGLtBN5cWACGrAkyM8RG2L799oUFudRN5LuJ+Cl13qXc7rTbKpnB5+nf9geUHkHr4ebVURLY5s/p03+5F1Ni8ZpSGcj7e1/ZDNrupPek3wFgfqYpq4GKjC90Q0LI/99Pgz9Ple/hy4XYXzrRXlpCD6p70WIY2A63oJkZvG6hAXd/l0jG5H5oZT3ELvMEyX1sKmcscGCFkGhv89XwvkYxXFtIKWWvuJsFseuP7ovpRk0="
    ];
  };
}
