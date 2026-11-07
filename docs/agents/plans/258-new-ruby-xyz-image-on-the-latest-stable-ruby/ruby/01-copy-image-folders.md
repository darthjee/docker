# Copy the ruby_331 family into ruby_3412/1.0.0
`bin/script.sh init` can't create a new image, so copy the three folders by hand. Every file is a copy of its `1.2.0` source (Dockerfile, `home/Gemfile`, `home/Gemfile.lock`, `README.md`, `test/test.sh`, `test/subtests/bundler.sh`). Later steps edit them.

```bash
for V in "" circleci_ production_; do
  mkdir -p ${V}ruby_3412
  cp -R ${V}ruby_331/1.2.0 ${V}ruby_3412/1.0.0
done
```

Commit the plain copy on its own, so the following diffs show only the real changes.

## Files to Change
- `ruby_3412/1.0.0/` — new, copied from `ruby_331/1.2.0/`.
- `circleci_ruby_3412/1.0.0/` — new, copied from `circleci_ruby_331/1.2.0/`.
- `production_ruby_3412/1.0.0/` — new, copied from `production_ruby_331/1.2.0/`.
