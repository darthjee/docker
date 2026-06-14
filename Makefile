all:
	bin/image.sh tag rails_bower
	bin/image.sh tag taa

rails_bower: version
	bin/image.sh build rails_bower

taa: version
	bin/image.sh build taa

node: version
	bin/image.sh build node

build:
	for IMAGE in $(IMAGES); do bin/image.sh build $$IMAGE; done

tag:
	for IMAGE in $(IMAGES); do bin/image.sh tag $$IMAGE; done

push:
	for IMAGE in $(IMAGES); do bin/image.sh push $$IMAGE; done

test:
	for IMAGE in $(IMAGES); do bin/image.sh test $$IMAGE; done
