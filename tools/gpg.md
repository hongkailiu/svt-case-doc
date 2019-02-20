# gpg

Doc:

* [gpg howto](https://www.gnupg.org/documentation/howtos.html)

Tested with Fodora 28

```
(awsenv) $ aws ec2 run-instances --image-id ami-f5fc948d     --security-group-ids sg-5c5ace38 --count 1 --instance-type m5.2xlarge --key-name id_rsa_perf     --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 30}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fedora28-test\"}]}]"

```

[generating-a-new-gpg-key](https://help.github.com/articles/generating-a-new-gpg-key/)

```
$ gpg2 --version
gpg (GnuPG) 2.2.6
libgcrypt 1.8.2
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Home: /home/fedora/.gnupg
Supported algorithms:
Pubkey: RSA, ELG, DSA, ECDH, ECDSA, EDDSA
Cipher: IDEA, 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH,
        CAMELLIA128, CAMELLIA192, CAMELLIA256
Hash: SHA1, RIPEMD160, SHA256, SHA384, SHA512, SHA224
Compression: Uncompressed, ZIP, ZLIB, BZIP2

$ gpg2 --full-generate-key
gpg (GnuPG) 2.2.6; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

gpg: directory '/home/fedora/.gnupg' created
gpg: keybox '/home/fedora/.gnupg/pubring.kbx' created
Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 
Key does not expire at all
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: Hongkai Liu
Email address: hongkailiu@users.noreply.github.com
Comment: 
You selected this USER-ID:
    "Hongkai Liu <hongkailiu@users.noreply.github.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: /home/fedora/.gnupg/trustdb.gpg: trustdb created
gpg: key 3976D3AE85706D3B marked as ultimately trusted
gpg: directory '/home/fedora/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/fedora/.gnupg/openpgp-revocs.d/56C4F8DBD49DB977EF1E23383976D3AE85706D3B.rev'
public and secret key created and signed.

pub   rsa4096 2018-11-06 [SC]
      56C4F8DBD49DB977EF1E23383976D3AE85706D3B
uid                      Hongkai Liu <hongkailiu@users.noreply.github.com>
sub   rsa4096 2018-11-06 [E]

$ gpg2 --list-secret-keys --keyid-format LONG

$ gpg2 --export --armor hongkailiu@users.noreply.github.com


```

More reading: [gpg tutorials](https://futureboy.us/pgp.html#PublicKeyCrypto), [how-to-encrypt-and-decrypt](https://linuxconfig.org/how-to-encrypt-and-decrypt-individual-files-with-gpg)

## 20190220: Fedora 29

[encryption/decryption](https://hashrocket.com/blog/posts/encryption-with-gpg-a-story-really-a-tutorial)

```
$ gpg --version
gpg (GnuPG) 1.4.23
...

$ gpg --gen-key

$ gpg --gen-revoke --armor --output=RevocationCertificate.asc hongkailiu@users.noreply.github.com

$ gpg --list-keys
/home/hongkliu/.gnupg/pubring.gpg
---------------------------------
pub   2048R/AA38B636 2019-02-20
uid                  Hongkai Liu <hongkailiu@users.noreply.github.com>
sub   2048R/5CA3EEBC 2019-02-20

$ gpg --list-secret-keys

### export public key
$ gpg --export -a hongkailiu@users.noreply.github.com > hongkailiu.github.pub
### export private key
$ gpg --export-secret-keys -a hongkailiu@users.noreply.github.com > hongkailiu.github.pri

### encrpytion (with public key)

### decryption
gpg --output <output.txt> <encrypted.file>

```

TODO