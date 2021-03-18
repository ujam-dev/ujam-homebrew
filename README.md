# Homebrew Cask Generator for UJAM Products

This script generates and tests Cask files for UJAM products.

Currently, only products that come without a downloader are supported.

## Usage

After updating `resources/products.yaml`, run the following scripts.

Generate Cask files:

```
./generate
```

Run audit and syntax check:

```
./test
```

Add, commit, create, and push branches for pull requests:

```
./push-branches
```

**Note:** You will still manually need to create the pull requests on GitHub.

## Hints

Enter Cask directory:

```
cd "$(brew --repository)/Library/Taps/homebrew/homebrew-cask/Casks"
```

_(This is for debugging purposes, not necessary when using the scripts above.)_

Clean up:

```
git checkout master
git pull
git push ujam-dev master --force
```

Delete all local branches except master:

```
git branch | grep -v '^*' | xargs git branch -D
```
