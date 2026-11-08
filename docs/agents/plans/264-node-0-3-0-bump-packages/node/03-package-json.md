# Pin and bump package.json
Rewrite `home/package.json` in `node/0.3.0` with every dependency pinned to an exact version: no `^`, `~`, `x` or `latest`. Each one is the latest release on its current major line. Then copy the file byte for byte to `circleci_node/0.3.0/home/package.json`. Leave `packages_sed.sed` unchanged.

| Package | Old | New |
|---|---|---|
| express | 4.22.0 | 4.22.3 |
| underscore | ~1.13.x | 1.13.8 |
| express-generator | latest | 4.16.1 |
| sass | ^1.69.0 | 1.108.1 |
| eslint | ^8.0.0 | 8.57.1 |
| eslint-config-standard | ^17.0.0 | 17.1.0 |
| eslint-plugin-complexity | ^1.0.2 | 1.0.2 |
| eslint-plugin-import | ^2.26.0 | 2.32.0 |
| eslint-plugin-jasmine | ^4.1.3 | 4.2.2 |
| eslint-plugin-n | ^15.3.0 | 15.7.0 |
| eslint-plugin-promise | ^6.0.1 | 6.6.0 |
| eslint-plugin-react | ^7.32.0 | 7.37.5 |
| eslint-plugin-react-hooks | ^4.6.0 | 4.6.2 |
| jasmine | ^5.0.0 | 5.13.0 |
| nyc | ^15.0.0 | 15.1.0 |
| plato | ^1.7.0 | 1.7.0 |

The `eslint-config-standard@17.1.0` peers (`eslint ^8.0.1`, `eslint-plugin-import ^2.25.2`, `eslint-plugin-n ^15 || ^16`, `eslint-plugin-promise ^6`) are all satisfied.

## Files to Change
- `node/0.3.0/home/package.json` — exact pins, bumped versions.
- `circleci_node/0.3.0/home/package.json` — identical copy.
