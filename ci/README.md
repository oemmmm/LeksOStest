# Сборка ISO в GitHub Actions

**Actions → ISO LeksOS → Run workflow.** Сборка идёт около часа: машина
GitHub ставит Arch в контейнере, качает пакеты из `[leksos]`, `[core]` и
`[extra]` и собирает образ из `LeksPlay` тем же `mkarchiso`, что и у вас.

Всё, что должно попасть в образ, сначала выложите в `[leksos]` на сервере:
сборка берёт пакеты оттуда, а не с вашего компьютера.

## Где образ

**Артефакт `leksos-iso`** на странице запуска (внизу, раздел Artifacts):
образ и его сумма `.sha256` в zip-архиве. Скачать его может только тот, кто
вошёл в GitHub. Хранится 14 дней.

**На сервере**, если заданы секреты (Settings → Secrets and variables →
Actions → New repository secret):

| Секрет | Что это |
|---|---|
| `ISO_SSH_KEY` | закрытый ключ SSH, только для этой выкладки |
| `ISO_SSH_TARGET` | куда класть, например `user@сервер:` или `user@сервер:/srv/leksos/iso/` |
| `ISO_SSH_KNOWN_HOSTS` | вывод `ssh-keyscan сервер` — чтобы не подсунули чужой сервер |

Ключ лучше сделать отдельный и разрешить ему только запись в один каталог:

```
ssh-keygen -t ed25519 -N '' -C leksos-iso-ci -f leksos-iso-ci
```

На сервере в `~/.ssh/authorized_keys` — строка с открытым ключом и
ограничением (`rrsync` входит в rsync 3.2.4 и новее):

```
command="rrsync -wo /srv/leksos/iso",restrict ssh-ed25519 AAAA... leksos-iso-ci
```

Тогда `ISO_SSH_TARGET` — просто `user@сервер:`, путь задаёт сам сервер, а
ключ, даже если он утечёт, не даст ни войти, ни прочитать или удалить файлы.
Содержимое `leksos-iso-ci` — в секрет `ISO_SSH_KEY`, сам файл удалите.

## Собрать у себя

Как и раньше, `./mk.sh` или `./buildiso.sh`.
