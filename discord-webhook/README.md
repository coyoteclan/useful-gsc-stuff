# Usage
- Add ``thread dsc_notifier::init();`` at the end of ``main()`` gametype function.
- Add ``self thread dsc_notifier::notifyDiscordConn(self.name);`` in ``PlayerConnect()`` callback.
- Add ``thread dsc_notifier::notifyDiscordDisconn(self.name);`` in ``PlayerDisconnect()`` callback.
- Add ``thread dsc_notifier::notifyDiscordKill(self.name, eAttacker.name, sWeapon, sMeansOfDeath);`` in ``PlayerKilled(...)`` callback.
