# sample-ota-esp32

Firmware hosting for pull-based OTA updates of the ESP32-2432S028R (CYD) demo.
This repo holds **only** the released binary and its manifest — no source code.
The source lives in the separate `ESP32_CYD_Demo` PlatformIO project.

| File | Purpose |
|---|---|
| `manifest.json` | `{"version": N, "url": "<firmware.bin URL>"}` — polled by the board |
| `firmware.bin` | Latest firmware image (PlatformIO `esp32dev` build) |
| `publish.sh` | Builds the project, updates both files, commits (optional push) |

## Board configuration

In the firmware project's `include/secrets.h`:

```c
#define OTA_MANIFEST_URL "https://raw.githubusercontent.com/chawatvish/sample-ota-esp32/main/manifest.json"
```

The repo must be **public** (the board cannot authenticate).

## Releasing an update

1. In the firmware project, raise `FW_VERSION` in `include/version.h`.
2. Run `./publish.sh` (or `PUSH=1 ./publish.sh` to also push).
3. The board updates within `OTA_CHECK_HOURS` (default 6), or immediately via the
   "Check update" button on `http://cyd.local`.

`raw.githubusercontent.com` caches for about 5 minutes, so a new release can take a
few minutes to be visible.

## Notes
- The board only updates when manifest `version` > its built-in `FW_VERSION`.
- No rollback: a firmware that crashes at boot needs a USB reflash.
- Do not commit secrets; `firmware.bin` contains the compiled firmware but `include/secrets.h`
  values (WiFi password etc.) **are compiled into it**. Keep this repo free of real credentials
  or make sure you are comfortable with them being public.
