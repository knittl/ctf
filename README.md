CTF-like shell exercises
========================

Build Docker images with dynamically-generated shell exercises. The goal is
to find and submit valid *tokens*.

Building
--------

1. Create a new text file in the `/config` directory, comprising two
columns: the user name and the user's real name.
2. Run `make secrets-${name_of_your_config_file}`
3. Run `make build-${name_of_your_config_file}`

Run `make build-${name_of_your_config_file}` again to regenerate all
exercises for the users in the given config file.

**IMPORTANT:** Generating new secrets invalidates all existing tokens!

Running
-------

Start a new contaier to solve the generated exercises:

```
docker run --rm -it knittl/ctf:${username_from_config_file}
```

Verifying tokens
----------------

Run `./verify.sh CTF config/${name_of_your_config_file}.secrets` and provide
the submitted tokens on standard input.
