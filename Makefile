unit-tests: dc-build unit-tests-dmd unit-tests-ldc

unit-tests-dmd:
	docker-compose run --rm dmd dub -q test --config=default
	docker-compose run --rm dmd dub build -b release --config=default
	docker-compose run --rm dmd dub -q test --config=requests-driver
	docker-compose run --rm dmd dub build -b release --config=requests-driver

unit-tests-ldc:
	docker-compose run --rm ldc dub -q test --config=default
	docker-compose run --rm ldc dub build -b release --config=default
	docker-compose run --rm ldc dub -q test --config=requests-driver
	docker-compose run --rm ldc dub build -b release --config=requests-driver

shell-dmd:
	docker-compose run --rm dmd bash

shell-ldc:
	docker-compose run --rm ldc bash

dc-build:
	docker-compose build

run-example-echobot:
	docker-compose run --workdir=/dlang/app/examples/echobot --rm example dub

run-example-keyboard:
	docker-compose run --workdir=/dlang/app/examples/keyboard --rm example dub

run-example-pollbot:
	docker-compose run --workdir=/dlang/app/examples/pollbot --rm example dub
