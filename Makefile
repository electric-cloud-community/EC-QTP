# Makefile

SRCTOP=..
include $(SRCTOP)/build/vars.mak

PLUGIN_PATCH_LEVEL=2.0.7

build: package
unittest:
systemtest: test-setup test-run
qtptest:
	$(MAKE) NTESTFILES="systemtest/qtp.ntest" RUNFLOGTESTS=1 test-setup test-run

NTESTFILES ?= systemtest

test-setup:
	$(EC_PERL) ../EC-QTP/systemtest/setup.pl $(TEST_SERVER) $(PLUGINS_ARTIFACTS)

test-run: systemtest-run

include $(SRCTOP)/build/rules.mak

test: build install promote

install:
	ectool installPlugin ../../../out/common/nimbus/EC-QTP/EC-QTP.jar
 
promote:
	ectool promotePlugin EC-QTP
