# QA

Compose files related to QA tasks / testing 

## Test Runners/Suites
- `test-runner.yml`
   Provides the [owncloudci/php](https://hub.docker.com/r/owncloudci/php/) image - which can be used for running scripts/tests inside
   By default uses `latest` tag, can be overridden via `OWNCLOUD_CI_IMAGE_TAG`

- `test-smashbox.yml`
    Provides the ability to bootstrap a smashbox runner against the defined environment  
    By default it will test with `http://owncloud` with user `admin` and password `admin` and `basicSync`  
    It can be configured via environment variables.  
    For full list of available environment variables please see  [owncloud-docker/smashbox#available-environment-variables](https://github.com/owncloud-docker/smashbox#available-environment-variables)

    **Available test suites**  
    For available test-suites, please see [owncloud/smashbox](https://github.com/owncloud/smashbox/tree/master/lib)  
    
    Note: test suites do only require the name (no need for prefix `test_` or writing a directory name)

## Selenium (UI tests)

If you require selenium for executing your test, you can include the following definitions

- `selenium_firefox_standalone.yml`  
  Provides [selenium/standalone-firefox](https://hub.docker.com/r/selenium/standalone-firefox/)  
  By default tag `latest` is used for the container, can be overridden via `FIREFOX_SELENIUM_VERSION`  

- `selenium_firefox_standalone_debug.yml`  
  Provides [selenium/standalone-firefox-debug](https://hub.docker.com/r/selenium/standalone-firefox-debug/)  
  same as `selenium_firefox_standalone.yml` but also provides a VNC access to be able to see the test running live. The port to VNC is "5900" and the password is set to "secret"

- `selenium_chrome_standalone.yml`
  Provides [selenium/standalone-chrome](https://hub.docker.com/r/selenium/standalone-chrome/)  
  By default tag `latest` is used for the container, can be overridden via `CHROME_SELENIUM_VERSION`  

- `selenium_chrome_standalone_debug.yml`  
  Provides [selenium/standalone-chrome-debug](https://hub.docker.com/r/selenium/standalone-chrome-debug/)  
  same as `selenium_chrome_standalone.yml` but also provides a VNC access to be able to see the test running live. The port to VNC is "5900" and the password is set to "secret"

- `zalenium.yml`
  Provides [dosel/zalenium](https://hub.docker.com/r/dosel/zalenium/)
  the advantages of the zalenium container are:
    - provides a video recording of the tests (by default saved into `/tmp/video` on the host)
    - provides a dashboard listing all tests with configurations and logs (reachable on the host via http://localhost:4444/dashboard/)
    - provides Firefox and Chrome in one container

- `owncloud-mount-tests.yml`
  Mounts the skeleton folder, the testing app into the docker container and disables ssl in apache (to make federation sharing possible without having to import self-signed certificates)
  `./core/apps/testing` is used as skeleton folder for UI tests, can be overridden via `OWNCLOUD_TESTINGAPP_FOLDER`
  The testing app is mounted from `./core/apps/testing`, can be overridden via `OWNCLOUD_TESTINGAPP_FOLDER`

### run UI tests inside of a docker container
In this case the owncloud core is mounted into the docker container and all tests run inside that container.
The complete source code including the test infrastructure is required inside the container. This will be the version of owncloud that gets tested.

1. clone owncloud into `./owncloud` or set the `OWNCLOUD_FOLDER` env. variable to your ownloud folder
1. run `make` inside `$OWNCLOUD_FOLDER`
1. start docker by mounting `$OWNCLOUD_FOLDER` into the container e.g. `docker-compose -f owncloud-base.yml -f owncloud-mount-oc.yml -f database/postgres.yml -f qa/selenium_chrome_standalone_debug.yml -f qa/owncloud-mount-tests.yml up`
1. run the tests `docker exec -it -u www-data composeinfrastructure_owncloud_1 bash tests/travis/start_ui_tests.sh`
you can use `--feature` or `--suite` to run only a subset of the tests e.g. `--feature tests/ui/features/other/login.feature:11`

### run UI tests from the outside against an independent docker container
In this case all tests run outside docker. That makes it possible to test a specific docker image and/or a specific owncloud version. It is still necessary to clone the source code from git, but this is only requeired in order to have the test infrastructure available.

1. clone owncloud including all tests into `core` folder
1. run `make` inside `core`
1. start owncloud with the desired configuration e.g
`docker-compose -f owncloud-base.yml -f owncloud-official.yml -f database/postgres.yml -f qa/selenium_chrome_standalone_debug.yml -f qa/owncloud-mount-tests.yml up`
1. set test settings:
e.g
```
export BROWSER=chrome #chrome or firefox
export SELENIUM_HOST=`docker inspect --format '{{ .NetworkSettings.Networks.composeinfrastructure_default.IPAddress }}' composeinfrastructure_selenium_chrome_standalone_1` #replace by firefox or zalenium container name if you are using those
export SRV_HOST_NAME=`docker inspect --format '{{ .NetworkSettings.Networks.composeinfrastructure_default.IPAddress }}' composeinfrastructure_owncloud_1`
export REMOTE_FED_SRV_HOST_NAME=$SRV_HOST_NAME
export SKELETON_DIR=/mnt/skeleton
export SELENIUM_PORT=4444
export PLATFORM=Linux
```
1. start the tests `bash tests/travis/start_ui_tests.sh --remote`
you can use `--feature` or `--suite` to run only a subset of the tests e.g. `--feature tests/ui/features/other/login.feature:11`

## Mailhog

Mailhog is provided via the following compose files:

- `mailhog.yml`  
   Uses the official [mailhog container](https://hub.docker.com/r/mailhog/mailhog) - tag `latest`
   Owncloud is automatically configured to use mailhog for outgoing mails

- `mailhog-expose-webinterface.yml`  
   Allows exposing the mailhog web interface to the host system. 
   By default the web port is reachable at `9625` 
   Override via `MAILHOG_WEB_PORT` 
   
- `mailhog-exposed-smtp.yml`  
   Allows exposing the mailhog smtp port to the host system.  
   By default the smtp port is reachable at `9620` 
   Override via `MAILHOG_SMTP_PORT` 
