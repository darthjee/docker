# Build and test
Run the existing test suite for the dev image and both counterparts:

```bash
bin/script.sh test ruby_3412
```

It must print `All tests passed` for all three images (the `bundle check` subtest).

Then build each image for both architectures, without pushing:

```bash
for V in "" circleci_ production_; do
  docker buildx build --platform linux/amd64,linux/arm64 ${V}ruby_3412/1.0.0
done
```

Both architectures must build.

## Files to Change
- None. This step only verifies.
