## unfollows
Get email notifications about Twitter unfollowers


### Requeriments
##### cURL
`apt-get install curl` (if you don't already have it).

#### oauth_sign
An OAuth library for the CLI.

Get the [tarball](http://acme.com/software/oauth_sign/), compile and move the binary to wherever `unfollows.sh` is.

#### jq
A JSON parser for the CLI.

Just get the [binary](http://stedolan.github.io/jq/download/) and you are ready to go. Place it along with `unfollows.sh` too.


### Installation
Install the dependencies and edit the head of `unfollows.sh` with your configuration. You will need to [register](https://apps.twitter.com/app/new) a read-only app with Twitter and obtain one token and key.

### Known limitations
- The script will work with Twitter accounts up to 5000 followers.
- The script will not notify you about deleted or suspended accounts.
- The `-a` flag of mail works on Debian but doesn't in Mac OS X, so you may need to remove it.
