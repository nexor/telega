DC = docker compose

unit-tests: dc-build unit-tests-dmd unit-tests-ldc

unit-tests-dmd:
	$(DC) run --rm dmd dub -q test --config=default
	$(DC) run --rm dmd dub build -b release --config=default
	$(DC) run --rm dmd dub -q test --config=requests-driver
	$(DC) run --rm dmd dub build -b release --config=requests-driver

unit-tests-ldc:
	$(DC) run --rm ldc dub -q test --config=default
	$(DC) run --rm ldc dub build -b release --config=default
	$(DC) run --rm ldc dub -q test --config=requests-driver
	$(DC) run --rm ldc dub build -b release --config=requests-driver

shell-dmd:
	$(DC) run --rm dmd bash

shell-ldc:
	$(DC) run --rm ldc bash

dc-build:
	$(DC) build

run-example-echobot:
	$(DC) -f docker-compose.examples.yml run --workdir=/dlang/app/examples/echobot --rm example dub

run-example-keyboard:
	$(DC) -f docker-compose.examples.yml run --workdir=/dlang/app/examples/keyboard --rm example dub

run-example-pollbot:
	$(DC) -f docker-compose.examples.yml run --workdir=/dlang/app/examples/pollbot --rm example dub
