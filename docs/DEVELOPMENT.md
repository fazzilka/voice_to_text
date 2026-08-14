# Разработка на macOS

## Окружение

Проверить систему:

```bash
uname -m
sw_vers -productVersion
swift --version
xcode-select -p
```

Ожидаются `arm64`, macOS 14+ и Swift 6 из Xcode Command Line Tools. Рабочий
каталог проекта: `~/petproject/voice_to_text`.

## Remotes

```bash
git remote -v
```

- `origin` — `git@github.com:fazzilka/voice_to_text.git`;
- `upstream` — `https://github.com/shlgd/SuperDictate.git`.

Upstream нужен для анализа исправлений исходного проекта. Обновления нельзя
сливать вслепую: сначала сравниваются изменения, затем нужные коммиты
переносятся в отдельной feature/fix ветке и повторно тестируются.

## Команды проверки

Быстрый цикл:

```bash
./scripts/check.sh
swift run --package-path core VoiceToTextCoreChecks
swift run -c debug --package-path swift VoiceToText --self-test all
```

Полная сборка:

```bash
./scripts/build-app.sh ./dist/VoiceToText.app
codesign --verify --deep --strict ./dist/VoiceToText.app
plutil -p ./dist/VoiceToText.app/Contents/Info.plist
```

`build-app.sh` проверяет macOS/arm64, собирает release binary, создаёт bundle,
добавляет ресурсы, применяет Hardened Runtime entitlements и проверяет подпись.

## Локальная установка

Постоянный путь только один:

```text
/Applications/VoiceToText.app
```

Для обновления установленной developer-сборки:

```bash
./scripts/install-local.sh
```

Скрипт ищет Apple Development identity и отказывается менять designated
requirement уже установленного приложения. Это сохраняет выданные TCC-права.
Никогда не запускайте одновременно копии из `dist`, `/tmp` и `/Applications`.

Посмотреть доступные сертификаты:

```bash
security find-identity -v -p codesigning
```

## Разрешения

Приложение не выдаёт разрешения само. Пользователь подтверждает:

- Microphone;
- Accessibility;
- Input Monitoring.

Не вызывайте `tccutil reset` из скриптов или тестов. Ручной сброс допустим
только когда пользователь осознанно хочет заново пройти permission flow.

## Логи и диагностика

```bash
tail -f ~/Library/Logs/VoiceToText.log
launchctl print gui/$(id -u)/com.fazzilka.voicetotext.agent
```

Самотесты предпочтительнее запуска временного `.app`:

```bash
swift run -c debug --package-path swift VoiceToText --self-test all
```

Имена отдельных suites можно найти командой:

```bash
rg 'case "|--self-test' swift/Sources/VoiceToText/main.swift
```

## Версионирование и release

Версия должна совпадать в:

- `swift/Info.plist`;
- `install.sh`;
- `update.json`;
- release-smoke workflow.

До публикации `v0.1.0` checksum состоит из нулей и обозначает отсутствие
готового публичного архива. При релизе:

1. собрать и проверить `VoiceToText.app`;
2. упаковать неизменяемый `VoiceToText.zip`;
3. вычислить SHA-256;
4. записать один checksum в `install.sh` и `update.json`;
5. создать tag/release только после merge release PR;
6. не заменять asset у уже опубликованной версии.

## Полное удаление данных

Обычный `./uninstall.sh` сохраняет данные. Полное удаление — отдельная ручная
операция пользователя после создания резервной копии:

```text
~/Library/Application Support/VoiceToText
~/Library/Preferences/com.fazzilka.voicetotext.plist
~/Library/Logs/VoiceToText*
```

Кэш FluidAudio может использоваться другими приложениями, поэтому uninstall
его намеренно не удаляет.
