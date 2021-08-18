WITH_ZYDIS      ?= y
WITH_LWIP       ?= y
WITH_TLSF       ?= n
WITH_MUSL       ?= n
WITH_NEWLIB     ?= n

UK_ROOT  ?= $(PWD)/../../unikraft
UK_LIBS  ?= $(PWD)/../../libs
UK_PLATS ?= $(PWD)/../../plats

LIBS-y                  := $(UK_LIBS)/libelf
LIBS-$(WITH_ZYDIS)      := $(LIBS-y):$(UK_LIBS)/zydis
LIBS-$(WITH_LWIP)       := $(LIBS-y):$(UK_LIBS)/lwip
PLATS-y                 :=

all:
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS-y) P=$(PLATS-y)

$(MAKECMDGOALS):
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS-y) P=$(PLATS-y) $(MAKECMDGOALS)
