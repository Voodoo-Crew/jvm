##  ------------------------------------------------------------------------  ##
##                                Build Project                               ##
##  ------------------------------------------------------------------------  ##

# .SILENT:

.EXPORT_ALL_VARIABLES:

# .IGNORE:
##  ------------------------------------------------------------------------  ##

APP_NAME := jvm

REPO_HOST := https://github.com
REPO_USER := Voodoo-Crew
REPO_URL := $(shell git ls-remote --get-url)
GIT_COMMIT := $(shell git rev-list --remove-empty --remotes --max-count=1 --date-order --reverse)
APP_REPO := ${REPO_HOST}/${REPO_USER}/${APP_NAME}.git

APP_LOGO := ./assets/BANNER

APP_ENV := $(shell cat NODE_ENV)
CODE_VERSION := $(shell cat ./VERSION)
APP_BANNER := $(shell cat "${APP_LOGO}")
APP_BRANCH := "${APP_ENV}-${CODE_VERSION}"

WD := $(shell pwd -P)
APP_DIRS := $(addprefix ${WD}/,build-* dist-* webroot)

DT = $(shell date +'%Y%m%d%H%M%S')

include ./bin/.bash_colors

##  ------------------------------------------------------------------------  ##

COMMIT_EXISTS := $(shell [ -e COMMIT ] && echo 1 || echo 0)
ifeq ($(COMMIT_EXISTS), 0)
$(file > COMMIT,${GIT_COMMIT})
$(warning ${BYellow}[${DT}] Created file [COMMIT]${NC})
endif

DIR_SRC := ${WD}/src
DIR_BUILD := ${WD}/build-${CODE_VERSION}
DIR_DIST := ${WD}/dist-${CODE_VERSION}
DIR_COMMIT := ${GIT_COMMIT}
DIR_WEB := ${WD}/webroot

##  ------------------------------------------------------------------------  ##
# Query the default goal.

ifeq ($(.DEFAULT_GOAL),)
.DEFAULT_GOAL := default
endif

##  ------------------------------------------------------------------------  ##
##                                  INCLUDES                                  ##
##  ------------------------------------------------------------------------  ##

include ./bin/Makefile.*

##  ------------------------------------------------------------------------  ##

.PHONY: default

default: all;

##  ------------------------------------------------------------------------  ##
# $(info [${DT}]${BYellow} Default goal is: [$(.DEFAULT_GOAL)]${NC});

.PHONY: test

test: banner state help banner;

##  ------------------------------------------------------------------------  ##

.PHONY: clone

clone:
	@  git clone -b ${APP_BRANCH} ${APP_REPO} 	\
	&& cd ${APP_NAME} 	\
	&& git pull 	\
	&& find . -type f -exec chmod 664 {} \; 	\
	&& find . -type d -exec chmod 775 {} \; 	\
	&& find . -type f -name "*.sh" -exec chmod 755 {} \;

##  ------------------------------------------------------------------------  ##

.PHONY: banner

banner:
	@ if [ -f "${APP_LOGO}" ]; then cat "${APP_LOGO}"; fi

logo:
	@ figlet-toilet --termwidth --font standard --filter border --filter gay " ${APP_NAME} " -E "utf8" > ${APP_LOGO} -k

##  ------------------------------------------------------------------------  ##

.PHONY: clean clean-all
.PHONY: clean-repo clean-src clean-deps
.PHONY: clean-build clean-dist clean-web clean-files

clean-all: clean clean-web clean-files

clean: clean-build clean-dist

clean-repo:
	@ ${RM} -rf ${APP_NAME}

clean-src:
	@ ${RM} ${DIR_SRC}

clean-build:
	@ ${RM} ${DIR_BUILD}

clean-dist:
	@ ${RM} ${DIR_DIST}

clean-web:
	@ rm -rf ${DIR_WEB}

clean-deps:
	@ rm -rf bower_modules/ \
		node_modules/;

clean-files:
	@ rm -rf ${APP_DIRS}  			\
		bitbucket-pipelines.yml		\
		codeclimate-config.patch	\
		_config.yml;

##  ------------------------------------------------------------------------  ##

.PHONY: rights

rights:
	@ find . -type f -exec chmod 664 {} \;
	@ find . -type d -exec chmod 775 {} \;
	@ find . -type f -name "*.sh" -exec chmod a+x {} \;

##  ------------------------------------------------------------------------  ##

.PHONY: setup build deploy dev

setup:
	@ npm i
	@ bower i

build:
	# @ NODE_ENV=${APP_ENV}; gulp build

deploy:
	# @ NODE_ENV=${APP_ENV}; gulp deploy

dev:
	# @ NODE_ENV=development gulp build

##  ------------------------------------------------------------------------  ##

.PHONY: rebuild redeploy

rebuild: build;

redeploy: rebuild deploy;

##  ------------------------------------------------------------------------  ##

.PHONY: all full cycle
#* means the word "all" doesn't represent a file name in this Makefile;
#* means the Makefile has nothing to do with a file called "all" in the same directory.

all: banner clean cycle;

full: clean-all all;

cycle: rights setup build deploy;

##  ------------------------------------------------------------------------  ##
