# Verify platform binaries before deploying

Documentation available during exam:
* https://github.com/kubernetes/kubernetes/releases

Additional reading:
* https://help.ubuntu.com/community/HowToSHA256SUM

# TL;DR

Verify shasums of kubernetes binaries after download. On Linux use `sha512sum`, on MacOS use `shasum` instead.

Checksums are always published.

## Hands On

Download [kubectl v1.22.4 for linux-amd64](https://dl.k8s.io/v1.22.4/kubernetes-client-linux-amd64.tar.gz) and verify it's checksum (2339c0a627f014ed86840cc3d21fdf84f1971427).

## Solution:

curl -LO https://dl.k8s.io/v1.22.4/kubernetes-client-linux-amd64.tar.gz
echo "2339c0a627f014ed86840cc3d21fdff4f1971427  kubernetes-client-linux-amd64.tar.gz" > sum
shasum -c sum

## Validation:

You should get a failure:
```
kubernetes-client-linux-amd64.tar.gz: FAILED
shasum: WARNING: 1 computed checksum did NOT match
```
