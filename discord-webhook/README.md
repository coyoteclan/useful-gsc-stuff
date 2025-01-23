# Usage
- Add ``thread dsc_notifier::init();`` at the end of ``main()`` gametype function.
- Add ``self thread dsc_notifier::notifyDiscordConn(self.name);`` in ``PlayerConnect()`` callback.
- Add ``thread dsc_notifier::notifyDiscordDisconn(self.name);`` in ``PlayerDisconnect()`` callback.
- Add ``thread dsc_notifier::notifyDiscordKill(self.name, eAttacker.name, sWeapon, sMeansOfDeath);`` in ``PlayerKilled(...)`` callback.
- Set ``scr_enablenotifier`` to `1` in your cfg file. E.g.

  ```set scr_enablenotifier 1```
- Put your webhook URL in ``scr_notifierwebhook``. E.g.

  ```set scr_notifierwebhook "https://discord.com/api/webhoYp......"```
