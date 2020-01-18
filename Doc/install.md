/etc/:
    susi.toml

/usr/local/bin/:
    susi.watch
    susi.start
    susi.stop
    susi
    runDebug.sh
    julia

/etc/systemd/system/:
    susi.service


Julia Packages:
        ArgParse

Duckling:
    Install to /opt/Duckling
        Haskell stck required, e.g. stack.
        Install as described here: https://tech.fpcomplete.com/haskell/get-started

        clone Duckling from https://github.com/facebook/duckling
        into /opt/Duckling
        change into ./duckling
        $ stack build

        it might be necessary to install libpcre
            apt–get install libpcre3 libpcre3–dev

        test-run with $ stack exec duckling-example-exe

        insert the correct installation dir to susi.toml
        (/opt/Duckling/duckling) with the leading / to enforce
        absolute path.

Sound:
    Volume gain set with alsamixer or (x11) pavucontrol
