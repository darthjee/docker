# Plan: Bump js-cookie, angular and underscore in taa / circleci_taa / production_taa (new image versions)

Issue: [229-bump-js-cookie-angular-and-underscore-in-taa-circleci-taa-production-taa-new-image-versions.md](../../issues/229-bump-js-cookie-angular-and-underscore-in-taa-circleci-taa-production-taa-new-image-versions.md)

## Overview
Create `taa`, `circleci_taa` and `production_taa` **1.7.0** from 1.6.1, built on `*rails_yarn:1.3.0` (#228). Bump `js-cookie` to 3.0.7, `angular` and `angular-route` to 1.8.3, `underscore` to 1.13.8 and `jquery` to 3.7.1, keeping the pins shared with `rails_yarn` 1.3.0 identical. All work belongs to the `ruby-node` specialist.

See [ruby-node.md](ruby-node.md) for the full plan.
