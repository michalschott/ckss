# Verify platform binaries before deploying

Documentation available during exam:
* https://github.com/kubernetes/kubernetes/releases

Additional reading:
* https://help.ubuntu.com/community/HowToSHA256SUM

# TL;DR

Verify shasums of kubernetes binaries after download. On Linux use `sha512sum`, on MacOS use `shasum` instead.

Checksums are always published.

## Hands On

Download [kubectl v1.19.6 for linux-amd64](https://dl.k8s.io/v1.19.6/kubernetes-client-linux-amd64.tar.gz) and verify it's checksum (89105850409f55f6ee29185f17dce4fcabf6b646a42a38cf9339c21d5113e950e0f032ff533116054ee743a65cc097184e18bd970733696b77745db9baf789ee).

## Solution:

curl -LO https://dl.k8s.io/v1.19.6/kubernetes-client-linux-amd64.tar.gz
echo "89105850409f55f6ee29185f17dce4fcabf6b646a42a38cf9339c21d5113e950e0f032ff533116054ee743a65cc097184e18bd970733696b77745db9baf789ee  kubernetes-client-linux-amd64.tar.gz" > sum
shasum -c sum

## Validation:

You should get a failure:
```
kubernetes-client-linux-amd64.tar.gz: FAILED
shasum: WARNING: 1 computed checksum did NOT match
```

Find proper checksum yourself and retry ;)
