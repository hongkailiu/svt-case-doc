# openssl


* [openssl.org](https://www.openssl.org/)
* tutorials: [1](https://www.keycdn.com/blog/openssl-tutorial), [2](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs),
and [3](https://pki-tutorial.readthedocs.io/en/latest/)

```
### tested with f29
$ openssl version
OpenSSL 1.1.1 FIPS  11 Sep 2018
$ sudo dnf update openssl
$ openssl version
OpenSSL 1.1.1b FIPS  26 Feb 2019

$ openssl version -a
OpenSSL 1.1.1b FIPS  26 Feb 2019
built on: Fri Mar 15 16:10:28 2019 UTC
platform: linux-x86_64
options:  bn(64,64) md2(char) rc4(16x,int) des(int) idea(int) blowfish(ptr) 
compiler: gcc -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -Wa,--noexecstack -Wa,--generate-missing-build-notes=yes -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPADLOCK_ASM -DPOLY1305_ASM -DZLIB -DNDEBUG -DPURIFY -DDEVRANDOM="\"/dev/urandom\"" -DSYSTEM_CIPHERS_FILE="/etc/crypto-policies/back-ends/openssl.config"
OPENSSLDIR: "/etc/pki/tls"
ENGINESDIR: "/usr/lib64/engines-1.1"
Seeding source: os-specific
engines:  rdrand dynamic 


```

Some commands:

```
$ openssl list -commands
$ openssl list -cipher-commands
```

[github](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key) suggests to use `ssh-keygen` which [uses openssl library](https://serverfault.com/questions/780476/generating-ssh-keys-with-openssl-or-ssh-keygen).

TODO: follow the steps in Tutorial 3 above.
