ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: tailscale

init: ./create_buckets.sh

tailscale:
	docker run --rm -e http_proxy=${http_proxy} -v $(ROOT_DIR):/opt/layer lambci/lambda:build-provided /opt/layer/build.sh

upload: ./upload.sh

publish: ./publish.sh
	
clean:
	rm -f tailscale.zip

