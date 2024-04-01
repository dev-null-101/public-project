# README
#### Project Date Started: 04/01/2024


#### git ssh config in jumpvm
ssh-keygen -b 1024 -f <key>

git clone -b master git@github.com:user/repository.git --single-branch --depth 1 --recurse-submodules=recursive -c core.sshCommand='ssh -i /path/to/private-key'

