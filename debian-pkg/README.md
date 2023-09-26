# instructions
Since I normally build on ubuntu, I'm using Vagrant to create a debian-11
VM as a clean environment to build from. The ansible playbook provided installs
all dependencies the system needs to build with.

So assuming the same setup:

```
vagrant up
vagrant ssh
cd /usr/src
sudo ./build.sh
```





## old
Put your gpg private key into the secret.txt file, add your secret key password into the GPG_PASS and run:
`DOCKER_BUILDKIT=1 docker build -f Dockerfile --build-arg GPG_PASS=<INSERT PASS> --secret id=mysecret,src=secret.txt .`

The container will build and sign a debian package. Currently it is only an amd64 package
(or native to whatever you build it on).

## Todo:
- Figure out how to build for other platforms.
- Determine if the dpush command will push all of the architectures of debs at once
- Test the other generated arch's on some of those platforms, either via qmeu or some actual devices (rpi should get one of the arms)
- Push the packages to mentors.debian.net
- Push the packages to gemfury to replace the checkinstall ones

## Notes:
To examine the package after it has been generated and signed use an interactive shell:
`docker exec -it <image hash> /bin/bash`

The generated debs will be in `/usr/src/`
