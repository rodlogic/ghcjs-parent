
.PHONY: all ghcjs ghcjs-prim clean

SANDBOX_PATH=$(shell pwd)/.cabal-sandbox/bin

all: ghcjs

clean:
	cabal sandbox delete || true
	cd cabal/Cabal && rm -f cabal.sandbox.config
	cd cabal/cabal-install && rm -f cabal.sandbox.config
	cd ghcjs && rm -f cabal.sandbox.config
	cd ghcjs-prim && rm -f cabal.sandbox.config

cabal.sandbox.config:
	git submodule init
	git submodule update
	cabal sandbox init

cabal/cabal.sandbox.config: cabal.sandbox.config
	cd cabal && cabal sandbox init --sandbox ../.cabal-sandbox

.cabal-sandbox/bin/cabal: cabal/cabal.sandbox.config
	cd cabal && cabal install ./Cabal ./cabal-install

ghcjs/cabal.sandbox.config: cabal.sandbox.config .cabal-sandbox/bin/cabal
	cd ghcjs && PATH=$(SANDBOX_PATH):$(PATH) cabal sandbox init --sandbox ../.cabal-sandbox

ghcjs-prim: .cabal-sandbox/bin/cabal
	PATH=$(SANDBOX_PATH):$(PATH) cabal install ./ghcjs-prim --reorder-goals --max-backjumps=-1

ghcjs: ghcjs-prim
	PATH=$(SANDBOX_PATH):$(PATH) cabal install ./ghcjs --reorder-goals --max-backjumps=-1 --force-reinstalls
