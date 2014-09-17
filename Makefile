
.PHONY: all ghcjs ghcjs-prim clean

SANDBOX_PATH=$(shell pwd)/.cabal-sandbox/bin

all: ghcjs-prim

clean:
	cabal sandbox delete || true
	cd cabal && rm -f cabal.sandbox.config
	cd ghcjs && rm -f cabal.sandbox.config
	cd ghcjs-prim && rm -f cabal.sandbox.config

cabal.sandbox.config:
	git submodule init
	git submodule update
	cabal sandbox init

cabal/cabal.sandbox.config: cabal.sandbox.config
	cd cabal && cabal sandbox init --sandbox ../.cabal-sandbox

.cabal-sandbox/bin/cabal: cabal/cabal.sandbox.config
	cd cabal && cabal install cabal-install


ghcjs/cabal.sandbox.config: cabal.sandbox.config .cabal-sandbox/bin/cabal
	cd ghcjs && PATH=$(SANDBOX_PATH):$(PATH) cabal sandbox init --sandbox ../.cabal-sandbox

ghcjs: ghcjs/cabal.sandbox.config
	cd ghcjs && PATH=$(SANDBOX_PATH):$(PATH) cabal install ghcjs


ghcjs-prim/cabal.sandbox.config: cabal.sandbox.config .cabal-sandbox/bin/cabal 
	cd ghcjs-prim && PATH=$(SANDBOX_PATH):$(PATH) cabal sandbox init --sandbox ../.cabal-sandbox

ghcjs-prim: ghcjs-prim/cabal.sandbox.config ghcjs
	cd ghcjs-prim && PATH=$(SANDBOX_PATH):$(PATH) cabal install ghcjs-prim
